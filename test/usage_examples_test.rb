# frozen_string_literal: true

require 'test_helper'

# Tests for README examples.
class TestUsageExample < Minitest::Test
  class Artist
    include Entitainer

    schema do
      attributes :name

      has_many :albums
    end
  end

  class Album
    include Entitainer

    schema do
      attributes :title,
                 :date

      belongs_to :artist
    end
  end

  def test_available_attributes
    got, err = capture_io do
      p Artist.available_attributes
      p Album.available_attributes
    end

    want = <<~OUTPUT
      [:id, :name]
      [:id, :title, :date, :artist_id]
    OUTPUT
    assert_predicate err, :empty?
    assert_equal want, got
  end

  def test_no_defined_attributes
    artist = Artist.new
    got, err = capture_io do
      p artist.defined_attributes
    end

    want = <<~OUTPUT
      []
    OUTPUT
    assert_predicate err, :empty?
    assert_equal want, got
  end

  def test_defined_attributes
    artist = Artist.new(name: 'Czarny motyl')
    got, err = capture_io do
      p artist.defined_attributes
      p artist.defined_attributes_with_values
    end

    want = <<~OUTPUT
      [:name]
      {:name=>\"Czarny motyl\"}
    OUTPUT
    assert_predicate err, :empty?
    assert_equal want, got
  end

  def test_setting_belongs_to
    got, err = capture_io do
      artist = Artist.new(id: 1, name: 'Czarny motyl')
      album = Album.new(title: 'Maszyna do robienia dymu', artist: artist)

      p album.artist.name
      p album.artist.id
      p album.artist_id
    end

    want = <<~OUTPUT
      "Czarny motyl"
      1
      1
    OUTPUT

    assert_predicate err, :empty?
    assert_equal want, got
  end

  def test_setting_has_many
    got, err = capture_io do
      artist = Artist.new(name: 'Czarny motyl') do |artist|
        artist.albums << Album.new(title: 'Maszyna do robienia dymu')
        artist.albums << Album.new(title: 'Maszyna do suszenia łez')
      end

      p artist.albums.map(&:title)
    end

    want = <<~OUTPUT
      ["Maszyna do robienia dymu", "Maszyna do suszenia łez"]
    OUTPUT

    assert_predicate err, :empty?
    assert_equal want, got
  end
end
