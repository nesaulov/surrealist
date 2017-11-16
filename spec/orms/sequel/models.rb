require 'sequel'

Sequel.extension :migration

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

SequelItem.insert(name: 'testing sequel')
