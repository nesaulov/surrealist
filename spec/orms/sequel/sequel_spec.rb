# frozen_string_literal: true

require_relative 'models'

RSpec.describe 'Sequel integration' do
  describe 'instances' do
    let(:subject) { instance.surrealize }

    describe '#first' do
      let(:instance) { SequelItem.first }

      it { is_expected.to eq({ name: 'SequelItem 0' }.to_json) }
      it_behaves_like 'error is not raised for valid params: instance'
      it_behaves_like 'error is raised for invalid params: instance'
    end

    describe '#first({ condition })' do
      let(:instance) { SequelItem.first(price: 4) }

      it { is_expected.to eq({ name: 'SequelItem 1' }.to_json) }
    end

    describe '#[]' do
      let(:instance) { SequelItem[3] }

      it { is_expected.to eq({ name: 'SequelItem 2' }.to_json) }
    end

    describe '#[{ condition }]' do
      let(:instance) { SequelItem[{ price: 12 }] }

      it { is_expected.to eq({ name: 'SequelItem 3' }.to_json) }
    end

    describe '#with_pk!' do
      let(:instance) { SequelItem.with_pk!(5) }

      it { is_expected.to eq({ name: 'SequelItem 4' }.to_json) }
    end

    describe '#last({ condition })' do
      let(:instance) { SequelItem.last(price: 20) }

      it { is_expected.to eq({ name: 'SequelItem 5' }.to_json) }
    end

    describe '#last' do
      let(:instance) { SequelItem.last }

      it { is_expected.to eq({ name: 'SequelItem 6' }.to_json) }
    end
  end

  describe 'collections' do
    let(:subject) { Surrealist.surrealize_collection(collection) }

    describe '#all' do
      let(:collection) { SequelItem.all }
      let(:serialized_collection) { (Array.new(7) { |i| { name: "SequelItem #{i}" } }).to_json }

      it { is_expected.to eq(serialized_collection) }
      it_behaves_like 'error is not raised for valid params: collection'
      it_behaves_like 'error is raised for invalid params: collection'
    end

    # In Sequel #where always returns an array
    describe '#where()' do
      let(:collection) { SequelItem.where(id: 2) }
      let(:serialized_collection) { [name: 'SequelItem 1'].to_json }

      it { is_expected.to eq(serialized_collection) }
      it_behaves_like 'error is not raised for valid params: collection'
      it_behaves_like 'error is raised for invalid params: collection'

      context 'with #select' do
        let(:collection) { SequelItem.select(:id, :name).order(:name).where(id: 2) }

        it { is_expected.to eq(serialized_collection) }
      end

      context 'with #all' do
        let(:collection) { SequelItem.where(id: 2).all }

        it { is_expected.to eq(serialized_collection) }
      end
    end

    describe '#where{}' do
      let(:collection) { SequelItem.where { price < 3 } }
      let(:serialized_collection) { [name: 'SequelItem 0'].to_json }

      it { is_expected.to eq(serialized_collection) }
      it_behaves_like 'error is not raised for valid params: collection'
      it_behaves_like 'error is raised for invalid params: collection'

      context 'with #select' do
        let(:collection) { SequelItem.select(:id, :name).where { price < 3 } }

        it { is_expected.to eq(serialized_collection) }
      end

      context 'with #all' do
        let(:collection) { SequelItem.where { price < 3 }.all }

        it { is_expected.to eq(serialized_collection) }
      end
    end

    describe 'with #select and necessary field not selected' do
      let(:collection) { SequelItem.select(:id, :price).where(id: 2) }
      let(:serialized_collection) { [name: nil].to_json }

      it('substitutes `null` as value') { is_expected.to eq(serialized_collection) }
    end
  end
end
