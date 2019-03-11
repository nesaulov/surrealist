# frozen_string_literal: true

TestStruct = Struct.new(:name, :other_param)

RSpec.describe Surrealist::Helper do
  describe 'serializing  a single struct' do
    let(:person) { TestStruct.new('John', 'Dow') }

    specify 'a struct is not treated as a collection' do
      expect(Surrealist::Helper.collection?(person)).to eq false
    end
  end
end
