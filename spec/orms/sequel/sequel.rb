require 'sequel'

Sequel.sqlite.create_table :test_sequels do
  String :name
end

class TestSequel < Sequel::Model
  include Surrealist

  json_schema { { name: String } }
end
TestSequel.insert(name: 'testing sequel')

# context 'sequel' do
#   it 'works' do
#     expect(subject.surrealize_collection(TestSequel.all))
#       .to eq([{ name: 'testing sequel' }].to_json)
#   end
# end
# context 'data mapper' do
#   it 'works' do
#     expect(subject.surrealize_collection(TestDataMapper.all))
#       .to eq([{ name: 'testing data mapper' }].to_json)
#   end
# end
# context 'rom' do
#   rom = ROM.container(:memory) do |conf|
#     conf.register_mapper(ItemsMapper)
#     conf.relation(:items) do
#       def all; as(:item_obj).to_a; end
#     end
#     conf.commands(:items) do
#       define(:create)
#     end
#   end
#   rom.command(:items).create.call(name: 'testing rom')
#   it 'works' do
#     expect(subject.surrealize_collection(rom.relation(:items).all))
#       .to eq([{ name: 'testing rom' }].to_json)
#   end
# end
