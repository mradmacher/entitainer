# frozen_string_literal: true

require 'test_helper'

class TestComparison < Minitest::Test
  class User
    include Entitainer

    schema do
      attributes :name
    end
  end

  def test_entities_are_equal_when_their_ids_are_equal
    assert_equal User.new(id: 1), User.new(id: 1)
  end

  def test_entities_are_equal_when_their_ids_are_equal_even_if_other_attributes_are_not
    assert_equal User.new(id: 1, name: 'John'), User.new(id: 1, name: 'Suzee')
  end

  def test_when_ids_not_defined_entities_are_equal_when_their_attributes_are
    user = User.new(name: 'John')

    assert_equal user, User.new(name: 'John')
    refute_equal user, User.new(name: 'Suzee')
  end

  def test_is_not_equal_to_nil
    refute_equal User.new(id: 1), nil
  end
end
