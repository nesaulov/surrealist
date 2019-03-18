# frozen_string_literal: true

RSpec.describe Surrealist::Helper do
  describe 'serializing  a single struct' do
    let(:person) { Struct.new(:name, :other_param).new('John', 'Dow') }

    specify 'a struct is not treated as a collection' do
      expect(Surrealist::Helper.collection?(person)).to eq false
    end
  end
end
