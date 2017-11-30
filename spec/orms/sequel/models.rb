require 'sequel'

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

class Artist < Sequel::Model
  include Surrealist

  one_to_many :albums

  json_schema { { name: String } }
end

class Album < Sequel::Model
  include Surrealist

  many_to_one :artist

  json_schema { { title: String, year: Integer } }
end

7.times { |i| Artist.insert(name: "Artist #{i}", age: (18 + i * 4)) }

Artist.each_with_index do |artist, i|
  artist.add_album(title: "Album #{i}", year: (1950 + i * 5))
end
