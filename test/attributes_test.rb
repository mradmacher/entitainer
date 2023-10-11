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
    assert_includes DummyUser.available_attributes, :id
  end

  def test_id_is_added_by_default_to_available_attributes
    assert_includes User.available_attributes, :id
  end

  def test_available_attributes
    assert_equal %i[id first_name last_name email], User.available_attributes
  end

  def test_defined_attributes_are_empty_when_nothing_passed_to_initialize
    user = User.new

    assert_predicate user.defined_attributes, :empty?
  end

  def test_attributes_are_assigned_values_after_initialization
    user = User.new(first_name: 'Joe', last_name: 'Doe')

    assert_equal %i[first_name last_name], user.defined_attributes
    assert_equal %i[first_name last_name], user.defined_attributes_with_values.keys
    assert_equal 'Joe', user.defined_attributes_with_values[:first_name]
    assert_equal 'Doe', user.defined_attributes_with_values[:last_name]
  end

  def test_nil_is_treated_as_attribute_value
    user = User.new(id: 1, email: nil)

    assert_equal %i[id email], user.defined_attributes
    assert_equal %i[id email], user.defined_attributes_with_values.keys
    assert_equal 1, user.defined_attributes_with_values[:id]
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
