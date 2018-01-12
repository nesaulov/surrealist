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



RSpec.describe Surrealist::Serializer do
  describe 'Explicit surrealization through `Serializer.new`' do
    describe 'instance' do
      let(:instance) { Doge.new('John') }
      let(:expectation) { { name: 'John', name_length: 4 }.to_json }
      subject(:json) { DogeSerializer.new(instance).surrealize }

      it { is_expected.to eq expectation }
      it_behaves_like 'error is raised for invalid params: instance'
      it_behaves_like 'error is not raised for valid params: instance'

      describe 'passing context to serializer' do
        let(:milk) { Struct.new(:amount).new(20) }
        let(:flour) { Struct.new(:amount).new(40) }
        let(:instance) { Pancake.new(milk) }
        let(:expectation) { { amount: 60, color: 'yellow' }.to_json }
        subject(:json) { PancakeSerializer.new(instance, flour: flour).surrealize }

        it { is_expected.to eq expectation }
      end
    end

    describe 'collection' do
      let(:collection) { [Doge.new('John'), Doge.new('Josh')] }
      let(:expectation) { [{ name: 'John', name_length: 4 }, { name: 'Josh', name_length: 4 }].to_json }
      subject(:json) { DogeSerializer.new(collection).surrealize }

      it { is_expected.to eq expectation }
      it_behaves_like 'error is raised for invalid params: collection'
      it_behaves_like 'error is not raised for valid params: collection'

      describe 'passing context to serializer' do
        let(:milk) { Struct.new(:amount).new(20) }
        let(:flour) { Struct.new(:amount).new(40) }
        let(:collection) { [Pancake.new(milk), Pancake.new(milk)] }
        let(:expectation) { [{ amount: 60, color: 'yellow' }, { amount: 60, color: 'yellow' }].to_json }
        subject(:json) { PancakeSerializer.new(collection, flour: flour).surrealize }

        it { is_expected.to eq expectation }
      end
    end
  end

  describe 'Implicit surrealization using .surrealize_with' do
    describe 'instance' do
      let(:instance) { Doge.new('George') }
      let(:expectation) { { name: 'George', name_length: 6 }.to_json }
      subject(:json) { instance.surrealize }

      it { is_expected.to eq expectation }
      it_behaves_like 'error is raised for invalid params: instance'
      it_behaves_like 'error is not raised for valid params: instance'
    end

    describe 'collection' do
      let(:collection) { [Doge.new('Wow'), Doge.new('Doge')] }
      let(:expectation) { [{ name: 'Wow', name_length: 3 }, { name: 'Doge', name_length: 4 }].to_json }
      subject(:json) { Surrealist.surrealize_collection(collection) }

      it { is_expected.to eq expectation }
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
end
