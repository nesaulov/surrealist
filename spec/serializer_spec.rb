# frozen_string_literal: true

require 'surrealist'

class DogeSerializer < Surrealist::Serializer
  json_schema do
    { name: String, name_length: Integer }
  end

  def name_length
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

RSpec.describe Surrealist::Serializer do
  describe 'Explicit surrealization through `Serializer.new`' do
    describe 'instance' do
      let(:instance) { Doge.new('John') }
      subject(:json) { DogeSerializer.new(instance).surrealize }

      it { is_expected.to eq({ name: 'John', name_length: 4 }.to_json) }
      # it_behaves_like 'error is raised for invalid params: instance'
      # it_behaves_like 'error is not raised for valid params: instance'
    end

    describe 'collection' do
      let(:collection) { [Doge.new('John'), Doge.new('Josh')] }
      subject(:json) { DogeSerializer.new(collection).surrealize }

      it 'works' do
        expect(json)
          .to eq([{ name: 'John', name_lengh: 4 }, { name: 'Josh', name_lenght: 4 }].to_json)
      end
    end
  end

  describe 'Implicit surrealization using .surrealize_with' do
    let(:cat) { Doge.new('George').surrealize }

    it { expect(cat).to eq({ name: 'George', name_length: 6 }.to_json) }
  end
end
