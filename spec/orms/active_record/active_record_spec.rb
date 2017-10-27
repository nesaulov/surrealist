# frozen_string_literal: true

require_relative '../../../lib/surrealist'
require_relative 'models'
require_relative '../../carriers/params'

RSpec.describe 'ActiveRecord integration' do
  describe 'Surrealist.surrealize(ActiveRecord_Relation)' do
    let(:result) { Surrealist.surrealize_collection(collection) }

    context 'basics' do
      let(:collection) { Book.all }

      it 'works with #all' do
        expect(JSON.parse(result).length).to eq(3)
        expect(JSON.parse(result)).to be_a Array
      end
    end

    context 'inheritance' do
      let(:collection) { TestAR.all }

      it 'surrealizes children as well as parents' do
        expect(result).to eq(
          [
            { name: 'testing active record' },
            { name: 'testing active record inherit' },
            { name: 'testing active record inherit again' },
          ].to_json,
        )
      end

      it 'works with nested inheritance' do
        expect(Surrealist.surrealize_collection(InheritAR.all))
          .to eq(
            [{ name: 'testing active record inherit' },
             { name: 'testing active record inherit again' }].to_json,
          )

        expect(Surrealist.surrealize_collection(InheritAgainAR.all))
          .to eq([{ name: 'testing active record inherit again' }].to_json)
      end

      it 'fails with inheritance and without schema' do
        expect { Surrealist.surrealize_collection(SchemaLessAR.all) }
          .to raise_error Surrealist::UnknownSchemaError,
                          'Can\'t serialize SchemaLessAR - no schema was provided.'
      end
    end

    context 'scopes' do
      context 'query methods' do
        [
          -> { Surrealist.surrealize_collection(ARScope.coll_where) },
          -> { Surrealist.surrealize_collection(ARScope.coll_where_not) },
          -> { Surrealist.surrealize_collection(ARScope.coll_order) },
          -> { Surrealist.surrealize_collection(ARScope.coll_take) },
          -> { Surrealist.surrealize_collection(ARScope.coll_limit) },
          -> { Surrealist.surrealize_collection(ARScope.coll_offset) },
          -> { Surrealist.surrealize_collection(ARScope.coll_lock) },
          -> { Surrealist.surrealize_collection(ARScope.coll_readonly) },
          -> { Surrealist.surrealize_collection(ARScope.coll_reorder) },
          -> { Surrealist.surrealize_collection(ARScope.coll_distinct) },
          -> { Surrealist.surrealize_collection(ARScope.coll_find_each) },
          -> { Surrealist.surrealize_collection(ARScope.coll_select) },
          -> { Surrealist.surrealize_collection(ARScope.coll_group) },
          -> { Surrealist.surrealize_collection(ARScope.coll_order) },
          -> { Surrealist.surrealize_collection(ARScope.coll_except) },
          -> { Surrealist.surrealize_collection(ARScope.coll_extending) },
        ].each do |lambda|
          it 'works if scope returns collection of records' do
            expect { lambda.call }.not_to raise_error
          end
        end
      end

      context 'finder methods' do
        [
          -> { Surrealist.surrealize_collection(ARScope.rec_find_by) },
          -> { Surrealist.surrealize_collection(ARScope.rec_find_by!) },
          -> { Surrealist.surrealize_collection(ARScope.rec_find) },
          -> { Surrealist.surrealize_collection(ARScope.rec_take!) },
          -> { Surrealist.surrealize_collection(ARScope.rec_first) },
          -> { Surrealist.surrealize_collection(ARScope.rec_first!) },
          -> { Surrealist.surrealize_collection(ARScope.rec_second) },
          -> { Surrealist.surrealize_collection(ARScope.rec_second!) },
          -> { Surrealist.surrealize_collection(ARScope.rec_third) },
          -> { Surrealist.surrealize_collection(ARScope.rec_third!) },
          -> { Surrealist.surrealize_collection(ARScope.rec_fourth) },
          -> { Surrealist.surrealize_collection(ARScope.rec_fourth!) },
          -> { Surrealist.surrealize_collection(ARScope.rec_fifth) },
          -> { Surrealist.surrealize_collection(ARScope.rec_fifth!) },
          -> { Surrealist.surrealize_collection(ARScope.rec_forty_two) },
          -> { Surrealist.surrealize_collection(ARScope.rec_forty_two!) },
          -> { Surrealist.surrealize_collection(ARScope.rec_third_to_last) },
          -> { Surrealist.surrealize_collection(ARScope.rec_third_to_last!) },
          -> { Surrealist.surrealize_collection(ARScope.rec_second_to_last) },
          -> { Surrealist.surrealize_collection(ARScope.rec_second_to_last!) },
          -> { Surrealist.surrealize_collection(ARScope.rec_last) },
          -> { Surrealist.surrealize_collection(ARScope.rec_last!) },
        ].each do |lambda|
          it 'fails if scope returns single record' do
            expect { lambda.call }.to raise_error Surrealist::InvalidCollectionError,
                                                  'Can\'t serialize collection - must respond to :each'
          end
        end
      end
    end

    context 'associations' do
      let(:first_book) do
        [
          { title:   'The Adventures of Tom Sawyer', genre: { name: 'Adventures' },
            awards: { title: 'Nobel Prize' } },
        ]
      end

      context 'has one' do
        let(:collection) { Book.joins(:publisher).limit(1) }

        it 'raises exception on single record reference' do
          expect { Surrealist.surrealize_collection(Book.first.publisher) }
            .to raise_error Surrealist::InvalidCollectionError
        end

        it 'works with query methods that return relations' do
          expect(result).to eq(first_book.to_json)
        end
      end

      context 'belongs to' do
        let(:collection) { Book.joins(:genre).limit(1) }

        it 'raises exception on single record reference' do
          expect { Surrealist.surrealize_collection(Book.first.genre) }
            .to raise_error Surrealist::InvalidCollectionError
        end

        it 'works with query methods that return relations' do
          expect(result).to eq(first_book.to_json)
        end
      end

      context 'has_many' do
        let(:collection) { Book.first.awards }

        it 'works' do
          expect(result).to eq(Array.new(3) { { title: 'Nobel Prize' } }.to_json)
        end
      end

      context 'has and belongs to many' do
        let(:collection) { Book.second.authors }

        it 'works both ways' do
          expect(Surrealist.surrealize_collection(Book.second.authors))
            .to eq([{ name: 'Jerome' }].to_json)

          expect(Surrealist.surrealize_collection(Author.first.books))
            .to eq(
              [
                { title: 'The Adventures of Tom Sawyer', genre: { name: 'Adventures' },
                  awards: { title: 'Nobel Prize' } },
              ].to_json,
            )
        end
      end
    end

    context 'includes' do
      let(:collection) { Book.includes(:authors) }

      it 'works' do
        expect(JSON.parse(result).length).to eq(3)
        expect(JSON.parse(result)).to be_a Array
      end
    end

    context 'joins' do
      let(:collection) { Book.joins(:genre) }

      it 'works' do
        expect(JSON.parse(result).length).to eq(3)
        expect(JSON.parse(result)).to be_a Array
      end
    end

    it 'works with valid surrealization params' do
      VALID_PARAMS.each do |i|
        expect { Surrealist.surrealize_collection(TestAR.all, **i) }
          .to_not raise_error
      end
    end

    it 'fails with invalid surrealization params' do
      INVALID_PARAMS.each do |i|
        expect { Surrealist.surrealize_collection(TestAR.all, **i) }
          .to raise_error ArgumentError
      end
    end
  end

  context 'not proper collection' do
    it 'fails' do
      expect { Surrealist.surrealize_collection(Object) }
        .to raise_error(Surrealist::InvalidCollectionError,
                        'Can\'t serialize collection - must respond to :each')
    end
  end
end
