require 'sequel'

Sequel.sqlite.create_table :test_sequels do
  String :name
end

class TestSequel < Sequel::Model
  include Surrealist

  json_schema do { name: String } end
end
TestSequel.insert(name: 'testing sequel')