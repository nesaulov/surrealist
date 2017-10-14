require 'sequel'

Sequel.sqlite.create_table :test_sequels do
  String :name
end

class TestSequel < Sequel::Model
  include Surrealist

  json_schema { { name: String } }
end
TestSequel.insert(name: 'testing sequel')
