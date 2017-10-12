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
    table.string :type
  end
  create_table :books do |table|
    table.column :name, :string
    table.column :author_id, :integer
  end
  create_table :authors do |table|
    table.column :name, :string
  end
end
class TestAR < ActiveRecord::Base
  include Surrealist
  json_schema do { name: String } end
end
TestAR.create(name: 'testing active record')

class InheritAR < TestAR; delegate_surrealization_to TestAR; end
InheritAR.create(name: 'testing active record inherit')

class InheritAgainAR < InheritAR; delegate_surrealization_to TestAR; end
InheritAgainAR.create(name: 'testing active record inherit again')

class InheritWithoutSchemaAR < TestAR; end

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
    @id, @name = attributes.values_at(:id, :name)
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

RSpec.shared_examples "some example" do |parameter|
  let(:something) { parameter }
  it "uses the given parameter" do
    expect(subject.surrealize_collection).to eq(parameter)
  end
end

RSpec.describe Surrealist do
  describe 'subject.surrealize_collection ORM collections' do
    context 'active record' do
      it 'works' do
        expect(subject.surrealize_collection(TestAR.all))
          .to eq([{name: 'testing active record'}.to_json,
            {name: 'testing active record inherit'}.to_json,
            {name: 'testing active record inherit again'}.to_json])
      end

      it 'works with inheritance' do
        expect(subject.surrealize_collection(InheritAR.all))
          .to eq([{name: 'testing active record inherit'}.to_json,
                  {name: 'testing active record inherit again'}.to_json])
      end

      it 'works with nested inheritance' do
        expect(subject.surrealize_collection(InheritAgainAR.all))
          .to eq([{name: 'testing active record inherit again'}.to_json])
      end

      it 'fails with inheritance and without schema' do
        InheritWithoutSchemaAR.create(name: 'testing active record inherit without schema')
        expect { subject.surrealize_collection(InheritWithoutSchemaAR.all) }
          .to raise_error Surrealist::UnknownSchemaError
        InheritWithoutSchemaAR.all.destroy_all
      end

      it 'works with valid surrelization params' do
        [
          { camelize: true,  include_namespaces: true, include_root: true, namespaces_nesting_level: 3 },
          { camelize: false, include_namespaces: true, include_root: true, namespaces_nesting_level: 3 },
          { camelize: false, include_namespaces: false, include_root: true, namespaces_nesting_level: 3 },
          { camelize: false, include_namespaces: false, include_root: false, namespaces_nesting_level: 3 },
          { camelize: true,  include_namespaces: false, include_root: false, namespaces_nesting_level: 3 },
          { camelize: true,  include_namespaces: true, include_root: false, namespaces_nesting_level: 3 },
          { camelize: true,  include_namespaces: false, include_root: true, namespaces_nesting_level: 3 },
          { camelize: true,  include_namespaces: false, include_root: true, namespaces_nesting_level: 435 },
          { camelize: true,  include_namespaces: false, include_root: true, namespaces_nesting_level: 666 },
        ].each do |i|
          expect { subject.surrealize_collection(TestAR.all, **i) }.to_not raise_error
        end
      end

      it 'fails with invalid surrealization params' do
        [
          { camelize: 'NO', include_namespaces: false, include_root: true, namespaces_nesting_level: 3 },
          { camelize: true, include_namespaces: 'false', include_root: true, namespaces_nesting_level: 3 },
          { camelize: true, include_namespaces: false, include_root: true, namespaces_nesting_level: 0 },
          { camelize: true, include_namespaces: false, include_root: false, namespaces_nesting_level: -3 },
          { camelize: true, include_namespaces: false, include_root: 'yep', namespaces_nesting_level: 3 },
          { camelize: 'NO', include_namespaces: false, include_root: true, namespaces_nesting_level: '3' },
          { camelize: 'NO', include_namespaces: false, include_root: true, namespaces_nesting_level: 3.14 },
          { camelize: Integer, include_namespaces: false, include_root: true, namespaces_nesting_level: 3 },
          { camelize: 'NO', include_namespaces: 'no', include_root: true, namespaces_nesting_level: '3.4' },
          { camelize: 'f', include_namespaces: false, include_root: 't', namespaces_nesting_level: true },
        ].each do |i|
          expect { subject.surrealize_collection(TestAR.all, **i) }.to raise_error ArgumentError
        end
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