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
