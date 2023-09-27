# frozen_string_literal: true

require 'optiomist'

module Entitainer
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def available_attributes
      @available_attributes || []
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

    def attributes(*list)
      (list.include?(:id) ? list : [:id] + list).each do |attr|
        @available_attributes << attr
        define_accessor_for(attr)
      end
    end

    def belongs_to(*list)
      @available_belongs_tos = []
      list.each do |attr|
        @available_belongs_tos << attr
        define_accessor_for(attr)

        relation_id_attr = "#{attr}_id".to_sym
        unless @available_attributes.include?(relation_id_attr)
          @available_attributes << relation_id_attr
          define_accessor_for(relation_id_attr)
        end

        define_method("#{attr}=") do |obj|
          instance_variable_set("@#{attr}_id", Optiomist.some(obj&.id))
          instance_variable_set("@#{attr}", Optiomist.some(obj))
        end
      end
    end

    # rubocop:disable Naming/PredicateName
    def has_many(*list)
      @available_has_manys = []
      list.each do |attr|
        @available_has_manys << attr
        define_method(attr) do
          instance_variable_get("@#{attr}")
        end
      end
    end
    # rubocop:enable Naming/PredicateName

    private

    def define_accessor_for(attr)
      define_method(attr) do
        option = instance_variable_get("@#{attr}")
        option.value unless option.none?
      end
    end

  end

  def defined_attributes
    self.class.available_attributes.select do |attr|
      instance_variable_get("@#{attr}").some?
    end
  end

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

  # TODO: think if it should be here at all
  def cmp_with(other)
    instance_of?(other.class) && (
      (!id.nil? && !other.id.nil? && id == other.id) ||
      defined_attributes == other.defined_attributes
    )
  end
end
