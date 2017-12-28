# frozen_string_literal: true

require 'surrealist'

class KoshkaSerializer < Surrealist::Serializer
  json_schema do
    { name: String, size: Integer }
  end

  def size
    name.length
  end
end

class Koshka
  include Surrealist

  surrealize_with KoshkaSerializer

  def initialize(name)
    @name = name
  end

  attr_reader :name
end

RSpec.describe Surrealist::Serializer do
  describe 'method missing?' do
    let(:cat) { Koshka.new('cat') }
    subject(:kek) { KoshkaSerializer.new(cat).surrealize }

    it { is_expected.to eq({ name: 'cat', size: 3 }.to_json) }
  end

  describe '.surrealize_with' do
    let(:cat) { Koshka.new('kitty').surrealize }

    it { expect(cat).to eq({ name: 'kitty', size: 3 }.to_json) }
  end
end
