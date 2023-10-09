# frozen_string_literal: true

require 'test_helper'

class TestHasMany < Minitest::Test
  class Journalist
    include Entitainer

    schema do
      attributes :name
      has_many :articles
    end
  end

  class Article
    include Entitainer

    schema do
      attributes :title
    end
  end

  def test_relation_can_be_added_in_constructor_block
    journalist = Journalist.new(name: 'Thruth Teller') do |j|
      j.articles << Article.new(title: 'Good Things 1')
      j.articles << Article.new(title: 'Good Things 2')
    end
    assert_equal %i[name], journalist.defined_attributes
    assert_equal ['Good Things 1', 'Good Things 2'], journalist.articles.map(&:title)
  end

  def test_relation_can_be_skipped
    journalist = Journalist.new(name: 'Thruth Teller')
    assert_predicate journalist.articles, :empty?
  end

  def test_relation_cannot_be_changed_after_constructing
    journalist = Journalist.new(name: 'Thruth Teller')

    assert_raises(FrozenError) do
      journalist.articles << Article.new(title: 'About Bad Things')
    end
  end
end
