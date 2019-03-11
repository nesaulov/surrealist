# frozen_string_literal: true

class DogeSerializer < Surrealist::Serializer
  json_schema { { name: String, name_length: Integer } }

  private def name_length
    name.length
  end
end

class Doge
  include Surrealist
  attr_reader :name

  surrealize_with DogeSerializer

  def initialize(name)
    @name = name
  end
end

# With context
class PancakeSerializer < Surrealist::Serializer
  json_schema { { amount: Integer, color: String } }

  def amount
    flour.amount + milk.amount
  end

  def flour
    context[:flour]
  end
end

class Pancake
  include Surrealist

  surrealize_with PancakeSerializer

  attr_reader :milk

  def initialize(milk)
    @milk = milk
  end

  def color
    'yellow'
  end
end

class WrongSerializer
  include Surrealist
  json_schema { { name: String } }
end

Names = Module.new do
  def user_name
    user.name
  end

  def mouse_name
    mouse.name
  end

  def cow_name
    cow.name
  end
end

TestSerializerClass = Class.new(Surrealist::Serializer) do
  prepend Names

  serializer_context :user
  json_schema { { id_num: Integer, user_name: String } }

  def id_num
    2
  end
end

Multiple = Class.new(Surrealist::Serializer) do
  prepend Names
  serializer_context :user, :mouse, :cow
  json_schema { { user_name: String, mouse_name: String, cow_name: String } }
end

Cow = Struct.new(:name)
Mouse = Struct.new(:name)

User = Class.new do
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

Plural = Class.new(Surrealist::Serializer) do
  prepend Names
  serializer_contexts :user, :mouse, :cow
  json_schema { { user_name: String, mouse_name: String, cow_name: String } }
end

class Foo
  def test
    'model test'
  end

  def new_test
    'model public method'
  end

  private

  def private_test
    'model private method'
  end

  def another_private
    'model private method'
  end
end

class FooSerializer < Surrealist::Serializer
  json_schema do
    { test: String, new_test: String, private_test: String, another_private: String }
  end

  def new_test
    'serializer public method'
  end

  private def private_test
    'serializer private method'
  end
end

class FooChildSerializer < FooSerializer
  json_schema do
    { new_test: String, private_test: String }
  end
end

TestStruct = Struct.new(:name, :other_param)

class TestStructSerializer < Surrealist::Serializer
  json_schema { { name: String, other_param: String } }
end

RSpec.describe Surrealist::Serializer do
  describe 'Explicit surrealization through `Serializer.new`' do
    describe 'instance' do
      let(:instance) { Doge.new('John') }

      describe '#surrealize' do
        let(:expectation) { { name: 'John', name_length: 4 }.to_json }
        subject(:json) { DogeSerializer.new(instance).surrealize }

        it { is_expected.to eq expectation }
        it_behaves_like 'error is raised for invalid params: instance'
        it_behaves_like 'error is not raised for valid params: instance'
      end

      describe '#build_schema' do
        let(:expectation) { { name: 'John', name_length: 4 } }
        subject(:hash) { DogeSerializer.new(instance).build_schema }

        it { is_expected.to eq expectation }
      end

      describe 'passing context to serializer' do
        let(:milk) { Struct.new(:amount).new(20) }
        let(:flour) { Struct.new(:amount).new(40) }
        let(:instance) { Pancake.new(milk) }

        describe '#surrealize' do
          let(:expectation) { { amount: 60, color: 'yellow' }.to_json }
          subject(:json) { PancakeSerializer.new(instance, flour: flour).surrealize }

          it { is_expected.to eq expectation }
        end

        describe '#build_schema' do
          let(:expectation) { { amount: 60, color: 'yellow' } }
          subject(:hash) { PancakeSerializer.new(instance, flour: flour).build_schema }

          it { is_expected.to eq expectation }
        end
      end

      describe 'serializing hash' do
        let(:milk) { Struct.new(:amount).new(20) }
        let(:flour) { Struct.new(:amount).new(40) }
        let(:instance) { { color: 'yellow', milk: milk } }

        describe '#surrealize' do
          subject(:json) { PancakeSerializer.new(instance, flour: flour).surrealize }
          let(:expectation) { { amount: 60, color: 'yellow' }.to_json }

          it { is_expected.to eq expectation }
        end

        describe '#surrealize with include root' do
          subject(:json) { PancakeSerializer.new(instance, flour: flour).surrealize(include_root: true) }
          # NOTE: include root doesn't work as well when we call serializer in such way
          let(:expectation) { { pancake_serializer: { amount: 60, color: 'yellow' } }.to_json }

          it { is_expected.to eq expectation }
        end

        describe '#surrealize with camelize' do
          let(:instance) { { name: 'Pepe' } }
          subject(:json) { DogeSerializer.new(instance, flour: flour).surrealize(camelize: true) }
          let(:expectation) { { name: 'Pepe', nameLength: 4 }.to_json }

          it { is_expected.to eq expectation }
        end
      end

      describe 'serializing  a single struct' do
        let(:person) { TestStruct.new('John', 'Dow') }
        let(:expectation) { { name: 'John', other_param: 'Dow' } }
        subject(:hash) { TestStructSerializer.new(person).build_schema }

        it { is_expected.to eq expectation }
      end
    end

    describe 'collection' do
      let(:collection) { [Doge.new('John'), Doge.new('Josh')] }

      describe '#surrealize' do
        let(:expectation) { [{ name: 'John', name_length: 4 }, { name: 'Josh', name_length: 4 }].to_json }
        subject(:json) { DogeSerializer.new(collection).surrealize }

        it { is_expected.to eq expectation }
        it_behaves_like 'error is raised for invalid params: collection'
        it_behaves_like 'error is not raised for valid params: collection'
      end

      describe '#build_schema' do
        let(:expectation) { [{ name: 'John', name_length: 4 }, { name: 'Josh', name_length: 4 }] }
        subject(:hash) { DogeSerializer.new(collection).build_schema }

        it { is_expected.to eq expectation }
      end

      describe 'passing context to serializer' do
        let(:milk) { Struct.new(:amount).new(20) }
        let(:flour) { Struct.new(:amount).new(40) }
        let(:collection) { [Pancake.new(milk), Pancake.new(milk)] }

        describe '#surrealize' do
          let(:expectation) { [{ amount: 60, color: 'yellow' }, { amount: 60, color: 'yellow' }].to_json }
          subject(:json) { PancakeSerializer.new(collection, flour: flour).surrealize }

          it { is_expected.to eq expectation }
        end

        describe '#build_schema' do
          let(:expectation) { [{ amount: 60, color: 'yellow' }, { amount: 60, color: 'yellow' }] }
          subject(:hash) { PancakeSerializer.new(collection, flour: flour).build_schema }

          it { is_expected.to eq expectation }
        end
      end

      describe 'collection of structs' do
        let(:person1) { TestStruct.new('John', 'Dow') }
        let(:person2) { TestStruct.new('Mountain', 'Dew') }
        let(:person3) { TestStruct.new('Harley', 'Queen') }
        let(:struct_collection) { [person1, person2, person3] }
        let(:expectation) do
          [
            { name: 'John', other_param: 'Dow' },
            { name: 'Mountain', other_param: 'Dew' },
            { name: 'Harley', other_param: 'Queen' },
          ]
        end

        subject(:json) { TestStructSerializer.new(struct_collection).build_schema }

        it { is_expected.to eq expectation }
      end
    end
  end

  describe 'Implicit surrealization using .surrealize_with' do
    describe 'instance' do
      let(:instance) { Doge.new('George') }

      describe '#surrealize' do
        let(:expectation) { { name: 'George', name_length: 6 }.to_json }
        subject(:json) { instance.surrealize }

        it { is_expected.to eq expectation }
        it_behaves_like 'error is raised for invalid params: instance'
        it_behaves_like 'error is not raised for valid params: instance'
      end

      describe '#build_schema' do
        let(:expectation) { { name: 'George', name_length: 6 } }
        subject(:hash) { instance.build_schema }

        it { is_expected.to eq expectation }
      end
    end

    describe 'collection' do
      let(:collection) { [Doge.new('Wow'), Doge.new('Doge')] }

      describe '#surrealize' do
        let(:expectation) { [{ name: 'Wow', name_length: 3 }, { name: 'Doge', name_length: 4 }].to_json }
        subject(:json) { Surrealist.surrealize_collection(collection) }

        it { is_expected.to eq expectation }
      end
    end
  end

  describe 'Wrong class specified in .surrealize_with' do
    [WrongSerializer, Integer, ActiveRecord].each do |klass|
      it 'raises error' do
        expect do
          Class.new do
            include Surrealist

            surrealize_with klass
          end
        end.to raise_error(ArgumentError, "#{klass} should be inherited from Surrealist::Serializer")
      end
    end
  end

  describe 'class methods' do
    let(:user) { User.new('Dave') }
    let(:args) { { mouse: Mouse.new('Pes'), cow: Cow.new('Cat'), user: user } }

    describe '.serializer_context' do
      context 'one method' do
        let(:instance) { TestSerializerClass.new(nil, **args) }
        let(:args) { { user: user } }

        it { expect(instance.build_schema).to eq(id_num: 2, user_name: 'Dave') }
      end

      context 'many methods' do
        let(:instance) { Multiple.new(nil, **args) }

        it { expect(instance.build_schema).to eq(user_name: 'Dave', mouse_name: 'Pes', cow_name: 'Cat') }
      end

      context 'with .serializer_context defined, but context not passed' do
        let(:instance) { Multiple.new(nil) }

        it { expect { instance.build_schema }.to raise_error(Surrealist::UndefinedMethodError) }
      end

      context 'invalid arguments' do
        ['string', nil, 2, Class, {}, []].each do |argument|
          it "raises ArgumentError for #{argument}" do
            expect do
              Class.new(Surrealist::Serializer) do
                serializer_context argument
              end
            end.to raise_error(ArgumentError, 'Please provide an array of symbols to `.serializer_context`')
          end
        end
      end
    end

    describe '.serializer_contexts' do
      context 'many methods' do
        let(:instance) { Plural.new(nil, **args) }

        it { expect(instance.build_schema).to eq(user_name: 'Dave', mouse_name: 'Pes', cow_name: 'Cat') }
      end
    end
  end

  describe 'method delegation' do
    let(:model) { Foo.new }
    let(:instance) { FooSerializer.new(model) }
    let(:hash) { instance.build_schema }

    context 'Kernel#test' do
      it 'does not invoke Kernel method when falling back on method_missing' do
        expect(hash[:test]).to eq('model test')
      end
    end

    context 'serializer precedence call' do
      it 'invokes the instance method instead of the object one' do
        expect(hash[:new_test]).to eq('serializer public method')
        expect(hash[:private_test]).to eq('serializer private method')
        expect(hash[:another_private]).to eq('model private method')
      end

      context 'when serializer inherited' do
        let(:instance) { FooChildSerializer.new(model) }
        let(:hash) { instance.build_schema }

        it 'prefer parent serializer method before object method with the same name' do
          expect(hash[:new_test]).to eq('serializer public method')
          expect(hash[:private_test]).to eq('serializer private method')
        end
      end
    end
  end
end
