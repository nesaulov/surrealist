# frozen_string_literal: true

require_relative 'models'

RSpec.describe 'Sequel integration' do
  # Basically, Sequel returns instance only on .first, .last and .[].
  # And instances are returned for all other methods.
  describe 'instances' do
    let(:subject) { instance.surrealize }

    describe '.first' do
      let(:instance) { Artist.first }

      it { is_expected.to eq({ name: 'Artist 0' }.to_json) }
      it_behaves_like 'error is not raised for valid params: instance'
      it_behaves_like 'error is raised for invalid params: instance'
    end

    describe '.first({ condition })' do
      let(:instance) { Artist.first(age: 22) }

      it { is_expected.to eq({ name: 'Artist 1' }.to_json) }
    end

    describe '.[]' do
      let(:instance) { Artist[3] }

      it { is_expected.to eq({ name: 'Artist 2' }.to_json) }
    end

    describe '.[{ condition }]' do
      let(:instance) { Artist[{ age: 30 }] }

      it { is_expected.to eq({ name: 'Artist 3' }.to_json) }
    end

    describe '.with_pk!' do
      let(:instance) { Artist.with_pk!(5) }

      it { is_expected.to eq({ name: 'Artist 4' }.to_json) }
    end

    describe '.last({ condition })' do
      let(:instance) { Artist.last(age: 38) }

      it { is_expected.to eq({ name: 'Artist 5' }.to_json) }
    end

    describe '.last' do
      let(:instance) { Artist.last }

      it { is_expected.to eq({ name: 'Artist 6' }.to_json) }
    end
  end

  describe 'collections' do
    let(:subject) { Surrealist.surrealize_collection(collection) }
    let(:all) { Array.new(7) { |i| { name: "Artist #{i}" } } }
    let(:serialized_collection) { all.to_json }

    describe '.all' do
      let(:collection) { Artist.all }

      it { is_expected.to eq(serialized_collection) }
      it_behaves_like 'error is not raised for valid params: collection'
      it_behaves_like 'error is raised for invalid params: collection'
    end

    # In Sequel #where always returns an array
    describe '.where()' do
      let(:collection) { Artist.where(id: 2) }
      let(:serialized_collection) { [name: 'Artist 1'].to_json }

      it { is_expected.to eq(serialized_collection) }
      it_behaves_like 'error is not raised for valid params: collection'
      it_behaves_like 'error is raised for invalid params: collection'

      context 'with .select' do
        let(:collection) { Artist.select(:id, :name).order(:name).where(id: 2) }

        it { is_expected.to eq(serialized_collection) }
      end

      context 'with .all' do
        let(:collection) { Artist.where(id: 2).all }

        it { is_expected.to eq(serialized_collection) }
      end

      context 'with .select and necessary field not selected' do
        let(:collection) { Artist.select(:id, :age).where(id: 2) }
        let(:serialized_collection) { [name: nil].to_json }

        it('substitutes `null` as value') { is_expected.to eq(serialized_collection) }
      end
    end

    describe '.where{}' do
      let(:collection) { Artist.where { age < 19 } }
      let(:serialized_collection) { [name: 'Artist 0'].to_json }

      it { is_expected.to eq(serialized_collection) }
      it_behaves_like 'error is not raised for valid params: collection'
      it_behaves_like 'error is raised for invalid params: collection'

      context 'with .select' do
        let(:collection) { Artist.select(:id, :name).where { age < 19 } }

        it { is_expected.to eq(serialized_collection) }
      end

      context 'with .all' do
        let(:collection) { Artist.where { age < 19 }.all }

        it { is_expected.to eq(serialized_collection) }
      end

      context 'with .select and necessary field not selected' do
        let(:collection) { Artist.select(:id, :age).where { age < 19 } }
        let(:result) { [name: nil].to_json }

        it('substitutes `null` as value') { is_expected.to eq(result) }
      end
    end

    describe 'ordering methods' do
      context '.order' do
        let(:collection) { Artist.order(:age) }

        it { is_expected.to eq(serialized_collection) }
      end

      context '.reverse' do
        let(:collection) { Artist.reverse(:age) }
        let(:serialized_collection) { all.reverse.to_json }

        it { is_expected.to eq(serialized_collection) }
      end
    end
  end

  describe 'associations' do
    describe 'many to one' do
      let(:subject) { instance.surrealize }
      let(:result) { { name: 'Artist 0' }.to_json }

      context '.first' do
        let(:instance) { Album.first.artist }

        it { is_expected.to eq(result) }
        it_behaves_like 'error is not raised for valid params: instance'
        it_behaves_like 'error is raised for invalid params: instance'
      end

      context '.where' do
        let(:instance) { Album.where(id: 1).first.artist }

        it { is_expected.to eq(result) }
      end

      context '.association_join' do
        let(:query) { Album.association_join(:artist).where { year < 1956 } }

        context 'instance' do
          let(:instance) { query.first }
          let(:result) { { title: 'Album 0', year: 1950 }.to_json }

          it { is_expected.to eq(result) }
        end

        context 'collection' do
          let(:subject) { Surrealist.surrealize_collection(collection) }
          let(:collection) { query.all }
          let(:result) { [{ title: 'Album 0', year: 1950 }, { title: 'Album 1', year: 1955 }].to_json }

          it { is_expected.to eq(result) }
        end
      end
    end

    describe 'one to many' do
      let(:subject) { Surrealist.surrealize_collection(collection) }
      let(:collection) { Artist.with_pk(2).albums }
      let(:result) { [title: 'Album 1', year: 1955].to_json }

      it { is_expected.to eq(result) }

      context '.first' do
        let(:subject) { collection.first.surrealize }
        let(:result) { { title: 'Album 1', year: 1955 }.to_json }

        it { is_expected.to eq(result) }
      end

      context '.where' do
        let(:instance) { Artist.where(age: 22).albums }

        it { is_expected.to eq(result) }
      end

      context '.association_join' do
        let(:query) { Artist.association_join(:albums).where { age >= 35 } }

        context 'instance' do
          let(:subject) { instance.surrealize }
          let(:instance) { query.first }
          let(:result) { { name: 'Artist 5' }.to_json }

          it { is_expected.to eq(result) }
        end

        context 'collection' do
          let(:collection) { query.all }
          let(:result) { [{ name: 'Artist 5' }, { name: 'Artist 6' }].to_json }
          let(:subject) { Surrealist.surrealize_collection(collection) }

          it { is_expected.to eq(result) }
        end
      end
    end

    describe 'one to one' do
      let(:subject) { instance.surrealize }
      let(:result) { { label_name: 'Label 0' }.to_json }

      context '.first' do
        let(:instance) { Album.first.label }

        it { is_expected.to eq(result) }
        it_behaves_like 'error is not raised for valid params: instance'
        it_behaves_like 'error is raised for invalid params: instance'
      end

      context '.where' do
        let(:instance) { Album.where(id: 1).first.label }

        it { is_expected.to eq(result) }
      end

      context '.association_join' do
        let(:query) { Album.association_join(:label).where { year < 1956 } }

        context 'instance' do
          let(:instance) { query.first }
          let(:result) { { title: 'Album 0', year: 1950 }.to_json }

          it { is_expected.to eq(result) }
        end

        context 'collection' do
          let(:subject) { Surrealist.surrealize_collection(collection) }
          let(:collection) { query.all }
          let(:result) { [{ title: 'Album 0', year: 1950 }, { title: 'Album 1', year: 1955 }].to_json }

          it { is_expected.to eq(result) }
        end
      end
    end

    describe 'many to many' do
      let(:subject) { Surrealist.surrealize_collection(collection) }

      context 'Artist -> Songs' do
        let(:collection) { Artist.first.songs }
        let(:result) { [{ title: 'Song 00' }, { title: 'Song 01' }].to_json }

        it { is_expected.to eq(result) }
        it_behaves_like 'error is not raised for valid params: collection'
        it_behaves_like 'error is raised for invalid params: collection'

        context '.where' do
          let(:collection) { Artist.where(songs: Song.last(2)) }
          let(:result) { [name: 'Artist 6'].to_json }

          it { is_expected.to eq(result) }
        end
      end

      context 'Song -> Artists' do
        let(:collection) { Song.first.artists }
        let(:result) { [{ name: 'Artist 0' }, { name: 'Artist 6' }].to_json }

        it { is_expected.to eq(result) }
        it_behaves_like 'error is not raised for valid params: collection'
        it_behaves_like 'error is raised for invalid params: collection'

        context '.where' do
          let(:collection) { Song.where(artists: Artist.first(1)) }
          let(:result) { [{ title: 'Song 00' }, { title: 'Song 01' }].to_json }

          it { is_expected.to eq(result) }
        end
      end
    end
  end
end
