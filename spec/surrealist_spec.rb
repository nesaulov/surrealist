# frozen_string_literal: true

require_relative '../lib/surrealist'

class Baz
  include Surrealist

  json_schema do
    {
      foo:    Integer,
      bar:    Array,
      nested: {
        left:  String,
        right: Boolean,
      },
    }
  end

  def foo
    4
  end

  def bar
    [1, 3, 5]
  end

  private

  def left
    'left'
  end

  def right
    true
  end

  # expecting:
  # {
  #   foo: 4, bar: [1, 3, 5], nested: {
  #     left: 'left',
  #     right: true
  #   }
  # }
end

class WrongTypes
  include Surrealist

  json_schema do
    { foo: Integer }
  end

  def foo
    'string'
  end

  # expecting: Surrealist::InvalidTypeError
end

class WithoutSchema
  include Surrealist

  def foo
    4
  end

  def bar
    9 * 3
  end

  def baz
    1
  end

  # expecting: Surrealist::UnknownSchemaError
end

class Parent
  private def foo
    'foo'
  end

  # expecting: see Child
end

class Child < Parent
  include Surrealist

  json_schema do
    {
      foo: String,
      bar: Array,
    }
  end

  def bar
    [1, 2]
  end

  # expecting: { foo: 'foo', bar: [1, 2] }
end

class WithAttrReaders
  include Surrealist

  attr_reader :foo, :bar

  json_schema do
    {
      foo: String,
      bar: Array,
    }
  end

  def initialize
    @foo = 'foo'
    @bar = [1, 2]
  end

  # expecting: { foo: 'foo', bar: [1, 2] }
end

class WithNil
  include Surrealist

  json_schema do
    { foo: NilClass }
  end

  def foo; end

  # expecting: { foo: nil }
end

class WithNull
  include Surrealist

  json_schema do
    { foo: String }
  end

  def foo; end

  # expecting: { foo: nil }
end

class WithNestedObjects
  include Surrealist

  json_schema do
    { foo: { bar: Integer } }
  end

  def foo
    Struct.new(:bar).new(123)
  end

  # expecting: { foo: { bar: 123 } }
end

class MultiMethodStruct
  include Surrealist

  json_schema do
    {
      foo: {
        bar: Integer,
        baz: String,
      },
    }
  end

  def foo
    Struct.new(:bar, :baz).new(123, 'string')
  end

  # expecting: { foo: { bar: 123, baz: 'string' } }
end

RSpec.describe 'Surrealist' do
  describe '#surrealize & #build_schema' do
    context 'with defined schema' do
      context 'with correct types' do
        it 'works' do
          expect(JSON.parse(Baz.new.surrealize))
            .to eq('foo' => 4, 'bar' => [1, 3, 5], 'nested' => {
              'left'  => 'left',
              'right' => true,
            })

          expect(Baz.new.build_schema)
            .to eq(foo: 4, bar: [1, 3, 5], nested: { left: 'left', right: true })
        end
      end

      context 'with wrong types' do
        it 'raises TypeError' do
          error_text = 'Wrong type for key `foo`. Expected Integer, got String.'

          expect { WrongTypes.new.surrealize }
            .to raise_error(Surrealist::InvalidTypeError, error_text)
          expect { WrongTypes.new.build_schema }
            .to raise_error(Surrealist::InvalidTypeError, error_text)
        end
      end

      context 'with inheritance' do
        it 'works' do
          instance = Child.new

          expect(JSON.parse(instance.surrealize)).to eq('foo' => 'foo', 'bar' => [1, 2])
          expect(instance.build_schema).to eq(foo: 'foo', bar: [1, 2])
        end
      end

      context 'with attr_readers' do
        it 'works' do
          instance = WithAttrReaders.new

          expect(JSON.parse(instance.surrealize)).to eq('foo' => 'foo', 'bar' => [1, 2])
          expect(instance.build_schema).to eq(foo: 'foo', bar: [1, 2])
        end
      end

      context 'with NilClass' do
        it 'works' do
          expect(JSON.parse(WithNil.new.surrealize)).to eq('foo' => nil)
          expect(WithNil.new.build_schema).to eq(foo: nil)
        end
      end

      context 'with nil values' do
        it 'returns null' do
          instance = WithNull.new

          expect(JSON.parse(instance.surrealize)).to eq('foo' => nil)
          expect(instance.build_schema).to eq(foo: nil)
        end
      end

      context 'with nested objects' do
        it 'tries to invoke the method on the object' do
          instance = WithNestedObjects.new

          expect(JSON.parse(instance.surrealize)).to eq('foo' => { 'bar' => 123 })
          expect(instance.build_schema).to eq(foo: { bar: 123 })
        end
      end

      context 'with multi-method struct' do
        it 'works' do
          instance = MultiMethodStruct.new

          expect(JSON.parse(instance.surrealize))
            .to eq('foo' => { 'bar' => 123, 'baz' => 'string' })

          expect(instance.build_schema)
            .to eq(foo: { bar: 123, baz: 'string' })
        end
      end
    end

    context 'with undefined schema' do
      it 'raises error on #surrealize' do
        expect { WithoutSchema.new.surrealize }
          .to raise_error(Surrealist::UnknownSchemaError,
                          "Can't serialize WithoutSchema - no schema was provided.")
      end
    end
  end
end
