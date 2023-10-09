# entitainer
Immutable representations of database entities.

Entitainer helps turning database relations into objects.
Simplifies defining entity attributes and relations between different entities.

# Examples

```
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
```

## Attributes
```
Artist.available_attributes
# => [:id, :name]
Album.available_attributes #
# => [:id, :title, :date, :artist_id]

artist = Artist.new
artist.defined_attributes
# => []
artist = Artist.new(name: 'Czarny motyl')
artist.defined_attributes
# => [:name]
artist.defined_attributes_with_values
# => {:name=>\"Czarny motyl\"}
```

## Belongs to relation
```
artist = Artist.new(id: 1, name: 'Czarny motyl')
album = Album.new(title: 'Maszyna do robienia dymu', artist: artist)

album.artist.name
# => "Czarny motyl"
album.artist.id
# => 1
album.artist_id
# => 1
```

## Has many relation
```
artist = Artist.new(name: 'Czarny motyl') do |artist|
  artist.albums << Album.new(title: 'Maszyna do robienia dymu')
  artist.albums << Album.new(title: 'Maszyna do suszenia łez')
end

artist.albums.map(&:title)
# => ["Maszyna do robienia dymu", "Maszyna do suszenia łez"]

```

