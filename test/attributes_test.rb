# frozen_string_literal: true

require 'test_helper'

class TestAttributes < Minitest::Test
  class DummyUser
    include Entitainer

    schema do
      # empty schema
    end
  end

  class User
    include Entitainer

    schema do
      attributes :first_name,
                 :last_name,
                 :email

    end
  end

  def test_id_is_added_even_for_empty_attribute_list
    assert DummyUser.available_attributes.include?(:id)
  end

  def test_id_is_added_by_default_to_available_attributes
    assert User.available_attributes.include?(:id)
  end

  def test_available_attributes
    assert_equal %i[id first_name last_name email], User.available_attributes
  end

  def test_attributes_are_assigned_values_after_initialization
    user = User.new

    assert_predicate user.defined_attributes, :empty?

    user = User.new(first_name: 'Joe', last_name: 'Doe')

    assert_equal %i[first_name last_name], user.defined_attributes
    assert %i[first_name last_name], user.defined_attributes_with_values.keys
    assert 'Joe', user.defined_attributes_with_values[:first_name]
    assert 'Doe', user.defined_attributes_with_values[:last_name]

    user = User.new(id: 1, first_name: 'Joe', email: nil, last_name: 'Doe')

    assert_equal %i[id first_name last_name email], user.defined_attributes
    assert %i[id first_name last_name email], user.defined_attributes_with_values.keys
    assert 1, user.defined_attributes_with_values[:id]
    assert 'Joe', user.defined_attributes_with_values[:first_name]
    assert 'Doe', user.defined_attributes_with_values[:last_name]
    assert_nil user.defined_attributes_with_values[:email]
  end

  def test_unspecified_attributes_are_not_accessible_even_if_passed_for_initialization
    user = User.new(phone: '555-123-456')

    assert_predicate user.defined_attributes, :empty?
    assert_raises(NoMethodError) { user.phone }
  end

  def test_specified_but_skipped_during_initialization_attribute_has_nil_value
    user = User.new(first_name: 'Joe', last_name: 'Doe')

    assert_equal 'Joe', user.first_name
    assert_equal 'Doe', user.last_name
    assert_nil user.id
    assert_nil user.email
  end
end
