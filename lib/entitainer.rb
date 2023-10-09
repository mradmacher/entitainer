# frozen_string_literal: true

require 'optiomist'

# Turns your class into a database entity.
# Define attributes and relation in a _schema_ block
#   schema do
#     attributes :attr1, :attr2, :attr3
#     belongs_to :parent1, :parent2
#     has_many :items
#   end
#
# An _id_ attribute is always added automatically to the list.
#
# Also for <tt>belongs_to</tt> relation an attribute with the same name as
# the relation and <tt>_id</tt> suffix is added to the attribute list.
module Entitainer
  def self.included(base)
    base.extend(ClassMethods)
  end

  # Methods for schema definition.
  module ClassMethods
    # A collection of all available attributes defined in a schema block,
    # <tt>id</tt> attribute, and <tt>_id</tt> sufixed attribute for each
    # <tt>belongs_to</tt> relation.
    def available_attributes
      @available_attributes ||= []
    end

    def available_belongs_tos
      @available_belongs_tos ||= []
    end

    def available_has_manys
      @available_has_manys ||= []
    end

    def schema
      @available_attributes = []

      yield

      add_id_attribute
      define_methods

      define_method(:initialize) do |**args, &block|
        assign_values(args)
        assign_belongs_to(args)
        assign_has_many

        block&.call(self)

        freeze_it
      end

      define_method(:==) do |other|
        cmp_with(other)
      end
    end

    # Used in _schema_ block to define attributes available for the entity.
    def attributes(*list)
      list.each { |attr| @available_attributes << attr }
    end

    def belongs_to(*list)
      @available_belongs_tos = []
      list.each do |attr|
        @available_belongs_tos << attr

        relation_id_attr = "#{attr}_id".to_sym
        @available_attributes << relation_id_attr unless @available_attributes.include?(relation_id_attr)
      end
    end

    # rubocop:disable Naming/PredicateName
    def has_many(*list)
      @available_has_manys = []
      list.each { |attr| @available_has_manys << attr }
    end
    # rubocop:enable Naming/PredicateName

    private

    def add_id_attribute
      @available_attributes.prepend(:id) unless @available_attributes.include?(:id)
    end

    def define_methods
      available_attributes.each do |attr|
        define_accessor_for(attr)
      end

      available_belongs_tos.each do |attr|
        define_accessor_for(attr)

        define_method("#{attr}=") do |obj|
          instance_variable_set("@#{attr}_id", Optiomist.some(obj&.id))
          instance_variable_set("@#{attr}", Optiomist.some(obj))
        end
      end

      available_has_manys.each do |attr|
        define_method(attr) do
          instance_variable_get("@#{attr}")
        end
      end
    end

    def define_accessor_for(attr)
      define_method(attr) do
        option = instance_variable_get("@#{attr}")
        option.value unless option.none?
      end
    end
  end

  # List of attributes with an assigned value.
  def defined_attributes
    self.class.available_attributes.select do |attr|
      instance_variable_get("@#{attr}").some?
    end
  end

  # A hash where keys are attribute symbols and values are their values.
  # Only defined attributes are included.
  def defined_attributes_with_values
    {}.tap do |h|
      self.class.available_attributes.each do |attr|
        option = instance_variable_get("@#{attr}")
        h[attr.to_sym] = option.value unless option.none?
      end
    end
  end

  private

  def freeze_it
    freeze
    self.class.available_has_manys.each do |attr|
      instance_variable_get("@#{attr}").freeze
    end
  end

  def assign_values(args)
    self.class.available_attributes.each do |attr|
      instance_variable_set("@#{attr}", args.key?(attr) ? Optiomist.some(args[attr]) : Optiomist.none)
    end
  end

  def assign_belongs_to(args)
    self.class.available_belongs_tos.each do |attr|
      if args.key?(attr)
        send("#{attr}=", args[attr])
      else
        instance_variable_set("@#{attr}", Optiomist.none)
        instance_variable_set("@#{attr}_id", Optiomist.none)
      end
    end
  end

  def assign_has_many
    self.class.available_has_manys.each do |attr|
      instance_variable_set("@#{attr}", [])
    end
  end

  # They are considered equal if their ids are equal.
  # If both ids are nil, their defined attributes are compared for equality.
  def cmp_with(other)
    instance_of?(other.class) && (
      (!id.nil? && !other.id.nil? && id == other.id) ||
      defined_attributes_with_values == other.defined_attributes_with_values
    )
  end
end
