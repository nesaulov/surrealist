# frozen_string_literal: true

require_relative '../../../lib/surrealist'
require_relative 'models'
require_relative '../../carriers/params'

RSpec.describe 'ActiveRecord integration' do
  let(:Surrealist) { Surrealist }

  describe 'Surrealist.surrealize(ActiveRecord_Relation)' do
    let(:result) { Surrealist.surrealize_collection(collection) }

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
      it 'works with `bt` `ho`, `hm`, `habtm`' do
        #  TODO
      end

      it 'works' do
        expect(JSON.parse(Surrealist.surrealize_collection(Book.all)).length)
          .to eq(3)
        expect(JSON.parse(Surrealist.surrealize_collection(Book.all)))
          .to respond_to(:each)
      end

      it 'fails with belongs_to' do
        expect { Surrealist.surrealize_collection(Book.first.genre) }
          .to raise_error Surrealist::InvalidCollectionError
      end

      it 'fails with has_one' do
        expect { Surrealist.surrealize_collection(Book.first.publisher) }
          .to raise_error Surrealist::InvalidCollectionError
      end

      it 'works with has_many' do
        expect(JSON.parse(Surrealist.surrealize_collection(Book.first.awards)))
          .to respond_to(:each)
      end

      it 'works with has_and_belongs_to_many' do
        expect(JSON.parse(Surrealist.surrealize_collection(Book.first.authors)))
          .to respond_to(:each)
        expect(JSON.parse(Surrealist.surrealize_collection(Author.first.books)))
          .to respond_to(:each)
      end
    end

    context 'includes' do
      it 'works' do
        expect(JSON.parse(Surrealist.surrealize_collection(Book.includes(:authors))))
          .to respond_to(:each)
      end
    end

    context 'joins' do
      it 'works' do
        expect(JSON.parse(Surrealist.surrealize_collection(Book.joins(:genre))))
          .to respond_to(:each)
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
