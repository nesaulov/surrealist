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
    'test'
  end
end

class FooSerializer < Surrealist::Serializer
  json_schema { { test: String } }
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
    context 'Kernel#test' do
      let(:hash) { FooSerializer.new(Foo.new).build_schema }

      it 'does not invoke Kernel method when falling back on method_missing' do
        expect(hash).to eq(test: 'test')
      end
    end
  end
end
