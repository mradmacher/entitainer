# frozen_string_literal: true

require 'test_helper'

class TestBelongsTo < Minitest::Test
  class Artist
    include Entitainer

    schema do
      attributes :name
    end
  end

  class Album
    include Entitainer

    schema do
      attributes :title
      belongs_to :artist
    end
  end

  def test_relation_can_be_added_in_constructor
    artist = Artist.new(id: 1, name: 'The Big Star')
    album = Album.new(title: 'Only Gratest Hits', artist: artist)
    assert_equal %i[title artist_id], album.defined_attributes
    assert_equal artist.name, album.artist.name
    assert_equal artist.id, album.artist.id
    assert_equal artist.id, album.artist_id
    assert_equal artist, album.artist
  end

  def test_relation_can_go_without_id
    artist = Artist.new(name: 'The Big Star')
    album = Album.new(title: 'Only Gratest Hits') do |a|
      a.artist = artist
    end
    assert_equal %i[title artist_id], album.defined_attributes
    assert_equal artist.name, album.artist.name
    assert_nil album.artist.id
    assert_nil album.artist_id
    assert_equal artist, album.artist
  end

  def test_relation_can_be_added_in_constructor_block
    artist = Artist.new(id: 1, name: 'The Big Star')
    album = Album.new(title: 'Only Gratest Hits') do |a|
      a.artist = artist
    end
    assert_equal %i[title artist_id], album.defined_attributes
    assert_equal artist.name, album.artist.name
    assert_equal artist.id, album.artist.id
    assert_equal artist.id, album.artist_id
    assert_equal artist, album.artist
  end

  def test_relation_can_be_skipped
    album = Album.new(title: 'Only Gratest Hits')
    assert_equal %i[title], album.defined_attributes
    assert_nil album.artist
    assert_nil album.artist_id
  end

  def test_relation_can_be_nil
    album = Album.new(title: 'Only Gratest Hits', artist: nil)
    assert_equal %i[title artist_id], album.defined_attributes
    assert_nil album.artist
    assert_nil album.artist_id
  end

  def test_relation_cannot_be_changed_after_constructing
    artist = Artist.new(id: 1, name: 'The Big Star')
    album = Album.new(title: 'Only Gratest Hits', artist: artist)
    assert_raises(FrozenError) do
      album.artist = Artist.new(id: 2, name: 'The Big Loser')
    end
  end
end
