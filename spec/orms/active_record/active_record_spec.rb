# frozen_string_literal: true

require_relative 'models'
require_relative '../../../lib/surrealist'
require_relative '../../carriers/params'

RSpec.describe 'ActiveRecord integration' do
  collection_scopes = [
    -> { ARScope.coll_where },
    -> { ARScope.coll_where_not },
    -> { ARScope.coll_order },
    -> { ARScope.coll_take },
    -> { ARScope.coll_limit },
    -> { ARScope.coll_offset },
    -> { ARScope.coll_lock },
    -> { ARScope.coll_readonly },
    -> { ARScope.coll_reorder },
    -> { ARScope.coll_distinct },
    -> { ARScope.coll_find_each },
    -> { ARScope.coll_select },
    -> { ARScope.coll_group },
    -> { ARScope.coll_order },
    -> { ARScope.coll_except },
  ]

  record_scopes = [
    -> { ARScope.rec_find_by },
    -> { ARScope.rec_find_by! },
    -> { ARScope.rec_find },
    -> { ARScope.rec_take! },
    -> { ARScope.rec_first },
    -> { ARScope.rec_first! },
    -> { ARScope.rec_second },
    -> { ARScope.rec_second! },
    -> { ARScope.rec_third },
    -> { ARScope.rec_third! },
    -> { ARScope.rec_fourth },
    -> { ARScope.rec_fourth! },
    -> { ARScope.rec_fifth },
    -> { ARScope.rec_fifth! },
    -> { ARScope.rec_forty_two },
    -> { ARScope.rec_forty_two! },
    -> { ARScope.rec_last },
    -> { ARScope.rec_last! },
  ]

  collection_scopes.push(-> { ARScope.coll_extending }) unless ruby_22

  unless ruby_22
    record_scopes.push([
      -> { ARScope.rec_third_to_last },
      -> { ARScope.rec_third_to_last! },
      -> { ARScope.rec_second_to_last },
      -> { ARScope.rec_second_to_last! },
    ])
  end

  describe 'Surrealist.surrealize_collection()' do
    let(:result) { Surrealist.surrealize_collection(collection) }

    context 'basics' do
      let(:collection) { Book.all }

      it 'works with #all' do
        expect(JSON.parse(result).length).to eq(3)
        expect(JSON.parse(result)).to be_an Array
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
        collection_scopes.flatten.each do |lambda|
          it 'works if scope returns collection of records' do
            expect { Surrealist.surrealize_collection(lambda.call) }
              .not_to raise_error
          end
        end
      end

      context 'finder methods' do
        record_scopes.flatten.each do |lambda|
          it 'fails if scope returns single record' do
            expect { Surrealist.surrealize_collection(lambda.call) }
              .to raise_error Surrealist::InvalidCollectionError,
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
        expect(JSON.parse(result)).to be_an Array
      end
    end

    context 'joins' do
      let(:collection) { Book.joins(:genre) }

      it 'works' do
        expect(JSON.parse(result).length).to eq(3)
        expect(JSON.parse(result)).to be_an Array
      end
    end

    context 'parameters' do
      it 'works with valid surrealization params' do
        VALID_PARAMS.each do |i|
          expect { Surrealist.surrealize_collection(TestAR.all, **i) }
            .to_not raise_error
          expect(Surrealist.surrealize_collection(TestAR.all, **i))
            .to be_a String
        end
      end

      it 'fails with invalid surrealization params' do
        INVALID_PARAMS.each do |i|
          expect { Surrealist.surrealize_collection(TestAR.all, **i) }
            .to raise_error ArgumentError
        end
      end
    end

    context 'not a proper collection' do
      it 'fails' do
        expect { Surrealist.surrealize_collection(Object) }
          .to raise_error(Surrealist::InvalidCollectionError,
                          'Can\'t serialize collection - must respond to :each')
      end
    end
  end

  describe 'ActiveRecord instance #surrealize' do
    context 'scopes' do
      context 'query methods' do
        collection_scopes.flatten.each do |lambda|
          it 'fails if scope returns collection of records' do
            expect { lambda.call.surrealize }
              .to raise_error NoMethodError, /undefined method `surrealize' for/
          end
        end
      end

      context 'finder methods' do
        record_scopes.flatten.each do |lambda|
          it 'works if scope returns single record' do
            expect(lambda.call.surrealize)
              .to be_a String
            expect(JSON.parse(lambda.call.surrealize)).to have_key('title')
            expect(JSON.parse(lambda.call.surrealize)).to have_key('money')
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
        it 'works for a single record reference' do
          expect(Book.first.publisher.surrealize)
            .to eq('{"name":"Cengage Learning"}')
        end

        it 'fails with query methods that return relations' do
          expect { Book.joins(:publisher).limit(1).surrealize }
            .to raise_error NoMethodError, /undefined method `surrealize' for/
        end
      end

      context 'belongs to' do
        it 'works for a single record reference' do
          expect(Book.first.genre.surrealize)
            .to eq('{"name":"Adventures"}')
        end

        it 'fails with query methods that return relations' do
          expect { Book.joins(:genre).limit(1).surrealize }
            .to raise_error NoMethodError, /undefined method `surrealize' for/
        end
      end

      context 'has_many' do
        it 'fails' do
          expect { Book.first.awards.surrealize }
            .to raise_error NoMethodError, /undefined method `surrealize' for/
        end
      end

      context 'has and belongs to many' do
        it 'fails both ways' do
          expect { Book.second.authors.surrealize }
            .to raise_error NoMethodError, /undefined method `surrealize' for/

          expect { Author.first.books.surrealize }
            .to raise_error NoMethodError, /undefined method `surrealize' for/
        end
      end
    end
  end
end
