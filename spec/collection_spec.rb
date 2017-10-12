# frozen_string_literal: true

require_relative '../lib/surrealist'
require_relative './orms/ar'
require_relative './orms/sequel'
require_relative './orms/datamapper'
require_relative './orms/rom'
require_relative './carriers/params'

RSpec.describe Surrealist do
  describe 'subject.surrealize_collection ORM collections' do
    context 'active record' do
      it 'works' do
        expect(subject.surrealize_collection(TestAR.all))
          .to eq([{name: 'testing active record'}.to_json,
            {name: 'testing active record inherit'}.to_json,
            {name: 'testing active record inherit again'}.to_json])
      end

      it 'works with inheritance' do
        expect(subject.surrealize_collection(InheritAR.all))
          .to eq([{name: 'testing active record inherit'}.to_json,
                  {name: 'testing active record inherit again'}.to_json])
      end

      it 'works with nested inheritance' do
        expect(subject.surrealize_collection(InheritAgainAR.all))
          .to eq([{name: 'testing active record inherit again'}.to_json])
      end

      it 'fails with inheritance and without schema' do
        InheritWithoutSchemaAR.create(name: 'testing active record inherit without schema')
        expect { subject.surrealize_collection(InheritWithoutSchemaAR.all) }
          .to raise_error Surrealist::UnknownSchemaError
        InheritWithoutSchemaAR.all.destroy_all
      end

      it 'works with scopes' do
        expect(subject.surrealize_collection(TestAR.dummy))
          .to eq([{name: 'testing active record inherit'}.to_json])
      end

      context 'associations' do
        it 'works' do
          expect(subject.surrealize_collection(Book.all).length).to eq(3)
        end

        it 'fails with belongs_to' do
          expect { subject.surrealize_collection(Book.first.genre) }
            .to raise_error Surrealist::InvalidCollectionError
        end

        it 'fails with has_one' do
          expect { subject.surrealize_collection(Book.first.publisher) }
            .to raise_error Surrealist::InvalidCollectionError
        end

        it 'works with has_many' do
          expect(subject.surrealize_collection(Book.first.awards))
            .to respond_to(:each)
        end

        it 'works with has_and_belongs_to_many' do
          expect(subject.surrealize_collection(Book.first.authors))
            .to respond_to(:each)
          expect(subject.surrealize_collection(Author.first.books))
            .to respond_to(:each)
        end
      end

      it 'works with valid surrealization params' do
        VALID_PARAMS.each do |i|
          expect { subject.surrealize_collection(TestAR.all, **i) }.to_not raise_error
        end
      end

      it 'fails with invalid surrealization params' do
        INVALID_PARAMS.each do |i|
          expect { subject.surrealize_collection(TestAR.all, **i) }.to raise_error ArgumentError
        end
      end
    end
    context 'sequel' do
      it 'works' do
        expect(subject.surrealize_collection(TestSequel.all))
          .to eq([{name: 'testing sequel'}.to_json])
      end
    end
    context 'data mapper' do
      it 'works' do
        expect(subject.surrealize_collection(TestDataMapper.all))
          .to eq([{name: 'testing data mapper'}.to_json])
      end
    end
    context 'rom' do
      rom = ROM.container(:memory) do |conf|
        conf.register_mapper(ItemsMapper)
        conf.relation(:items) do
          def all; self.as(:item_obj).to_a; end
        end
        conf.commands(:items) do
          define(:create)
        end
      end
      rom.command(:items).create.call(name: 'testing rom')
      it 'works' do
        expect(subject.surrealize_collection(rom.relation(:items).all))
          .to eq([{name: 'testing rom'}.to_json])
      end
    end
    context 'not proper collection' do
      it 'fails' do
        expect { subject.surrealize_collection(Object) }
          .to raise_error(Surrealist::InvalidCollectionError,
            'Can\'t serialize collection - must respond to :each')
      end
    end
  end
end