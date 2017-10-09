# frozen_string_literal: true

require_relative '../lib/surrealist'

require 'active_record'
ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database  => ":memory:"
)
ActiveRecord::Schema.define do
  create_table :test_ars do |table|
      table.column :name, :string
  end
end
class TestAR < ActiveRecord::Base
  include Surrealist
  json_schema do { name: String } end
end
TestAR.create(name: 'testing active record')

require 'sequel'
Sequel.sqlite.create_table :test_sequels do
  String :name
end
class TestSequel < Sequel::Model
  include Surrealist
  json_schema do {name: String} end
end
TestSequel.insert(name: 'testing sequel')

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

require 'rom'
class Item
  include Surrealist
  json_schema do { name: String } end
  attr_reader :id, :name
  def initialize(attributes)
    @id, @name, @email = attributes.values_at(:id, :name)
  end
end
class ItemsMapper < ROM::Mapper
  register_as :item_obj
  relation :items
  model Item
end
rom = ROM.container(:memory) do |conf|
  conf.register_mapper(ItemsMapper)
  conf.relation(:items) do
    def all; self.as(:item_obj).to_a; end
  end
  conf.commands(:items) do
    define(:create)
  end
end
rom.command(:items).create.call(name: 'testing rom')

RSpec.describe Surrealist do
  describe 'subject.surrealize_collection ORM collections' do
    context 'active record' do
      it 'works' do
        expect(subject.surrealize_collection(TestAR.all))
          .to eq([{name: 'testing active record'}.to_json])
      end
    end
    context 'sequel' do
      it 'works' do
        expect(subject.surrealize_collection(TestSequel.all))
          .to eq([{name: 'testing sequel'}.to_json])
      end
    end
    context 'data mapper' do
      it 'works' do
        expect(subject.surrealize_collection(TestDataMapper.all))
          .to eq([{name: 'testing data mapper'}.to_json])
      end
    end
    context 'rom' do
      it 'works' do
        expect(subject.surrealize_collection(rom.relation(:items).all))
          .to eq([{name: 'testing rom'}.to_json])
      end
    end
    context 'not proper collection' do
      it 'fails' do
        expect { subject.surrealize_collection(Object) }
          .to raise_error(Surrealist::InvalidCollectionError,
            'Can\'t serialize collection - must respond to :each')
      end
    end
  end
end