require 'sequel'

DB = Sequel.sqlite

DB.create_table :sequel_items do
  primary_key :id
  String :name
  Float :price
end

class SequelItem < Sequel::Model
  include Surrealist

  json_schema { { name: String } }
end

7.times { |i| SequelItem.insert(name: "SequelItem #{i}", price: i * 4) }
