require 'data_mapper'

DataMapper.setup(:default, 'sqlite::memory:')

class TestDataMapper
  include DataMapper::Resource
  include Surrealist

  json_schema { { name: String } }

  property :id,   Serial
  property :name, Text
end

DataMapper.finalize.auto_upgrade!

TestDataMapper.create(name: 'testing data mapper')
