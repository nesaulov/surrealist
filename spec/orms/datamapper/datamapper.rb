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

# context 'data mapper' do
#   it 'works' do
#     expect(subject.surrealize_collection(TestDataMapper.all))
#       .to eq([{ name: 'testing data mapper' }].to_json)
#   end
# end
