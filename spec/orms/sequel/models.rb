# frozen_string_literal: true

require 'sequel'
require 'surrealist'

DB = Sequel.sqlite

DB.create_table :artists do
  primary_key :id
  String :name
  Float :age
end

DB.create_table :albums do
  primary_key :id
  foreign_key :artist_id, :artists, null: false
  String :title, unique: true
  Integer :year
end

DB.create_table :labels do
  primary_key :id
  foreign_key :album_id, :albums, null: false
  String :label_name
end

DB.create_table :songs do
  primary_key :id
  String :length
  String :title
end

DB.create_table :artists_songs do
  foreign_key :artist_id, :artists, null: false
  foreign_key :song_id, :songs, null: false
end

class Artist < Sequel::Model
  include Surrealist

  one_to_many :albums
  many_to_many :songs

  json_schema { { name: String } }
end

class Album < Sequel::Model
  include Surrealist

  many_to_one :artist
  one_to_one :label

  json_schema { { title: String, year: Integer } }
end

class Label < Sequel::Model
  include Surrealist

  one_to_one :album

  json_schema { { label_name: String } }
end

class Song < Sequel::Model
  include Surrealist

  many_to_many :artists

  json_schema { { title: String } }
end

class ArtistSerializer < Surrealist::Serializer
  json_schema { { name: String } }
end

class ArtistWithCustomSerializer < Sequel::Model(:artists)
  include Surrealist

  one_to_many :albums
  many_to_many :songs

  surrealize_with ArtistSerializer
end

7.times { |i| Artist.insert(name: "Artist #{i}", age: (18 + i * 4)) }

Artist.each_with_index do |artist, i|
  artist.add_album(title: "Album #{i}", year: (1950 + i * 5))
  2.times { |t| artist.add_song(title: "Song #{i}#{t}", length: (120 + i * 5)) }
end

Album.each_with_index do |album, i|
  Label.new(label_name: "Label #{i}", album_id: album.id).save
end

Song.each { |song| song.add_artist(Artist.last) }
