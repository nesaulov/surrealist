require 'data_mapper'

DataMapper.setup(:default, 'sqlite::memory:')

class TestDataMapper
  include DataMapper::Resource
  include Surrealist

  json_schema do { name: String } end

  property :id,   Serial
  property :name, Text
end

DataMapper.finalize.auto_upgrade!

TestDataMapper.create(name: 'testing data mapper')