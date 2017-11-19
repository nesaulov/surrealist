# frozen_string_literal: true

require_relative 'models'

RSpec.describe 'Sequel integration' do
  describe 'instances' do
    let(:subject) { instance.surrealize }

    context '#first' do
      let(:instance) { SequelItem.first }

      it { is_expected.to eq({ name: 'SequelItem 0' }.to_json) }
      it_behaves_like 'error is not raised for valid params: instance'
      it_behaves_like 'error is raised for invalid params: instance'
    end

    context '#first({ condition })' do
      let(:instance) { SequelItem.first(price: 4) }

      it { is_expected.to eq({ name: 'SequelItem 1' }.to_json) }
    end

    context '#[]' do
      let(:instance) { SequelItem[3] }

      it { is_expected.to eq({ name: 'SequelItem 2' }.to_json) }
    end

    context '#[{ condition }]' do
      let(:instance) { SequelItem[{ price: 12 }] }

      it { is_expected.to eq({ name: 'SequelItem 3' }.to_json) }
    end

    context '#with_pk!' do
      let(:instance) { SequelItem.with_pk!(5) }

      it { is_expected.to eq({ name: 'SequelItem 4' }.to_json) }
    end

    context '#last({ condition })' do
      let(:instance) { SequelItem.last(price: 20) }

      it { is_expected.to eq({ name: 'SequelItem 5' }.to_json) }
    end

    context '#last' do
      let(:instance) { SequelItem.last }

      it { is_expected.to eq({ name: 'SequelItem 6' }.to_json) }
    end
  end

  describe 'collections' do
    let(:collection) { SequelItem.all }
    let(:subject) { Surrealist.surrealize_collection(collection) }
    let(:expectation) { Array.new(7) { |i| { name: "SequelItem #{i}" } } }

    it { is_expected.to eq(expectation.to_json) }
    it_behaves_like 'error is not raised for valid params: collection'
    it_behaves_like 'error is raised for invalid params: collection'
  end
end
