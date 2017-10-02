# frozen_string_literal: true

require_relative '../lib/surrealist'

class Baz
  include Surrealist

  json_schema do
    {
      foo:    Integer,
      bar:    Array,
      anything: Any,
      nested: {
        left_side:  String,
        right_side: Bool,
      },
    }
  end

  def foo
    4
  end

  def bar
    [1, 3, 5]
  end

  protected

  def anything
    [{ some: 'thing' }]
  end

  private

  def left_side
    'left'
  end

  def right_side
    true
  end

  # expecting:
  # {
  #   foo: 4, bar: [1, 3, 5],
  #   anything: [{ some: 'thing' }],
  #   nested: {
  #     left_side: 'left',
  #     right_side: true
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
    { foo: { bar_bar: Integer } }
  end

  def foo
    Struct.new(:bar_bar).new(123)
  end

  # expecting: { foo: { bar_bar: 123 } }
end

class MultiMethodStruct
  include Surrealist

  json_schema do
    {
      foo: {
        bar_bar: Integer,
        baz_baz: String,
      },
    }
  end

  def foo
    Struct.new(:bar_bar, :baz_baz).new(123, 'string')
  end

  # expecting: { foo: { bar_bar: 123, baz_baz: 'string' } }
end

RSpec.describe Surrealist do
  describe '#surrealize & #build_schema' do
    context 'with defined schema' do
      context 'with correct types' do
        let(:instance) { Baz.new }

        it 'surrealizes' do
          expect(JSON.parse(instance.surrealize))
            .to eq('foo' => 4, 'bar' => [1, 3, 5], 'anything' => [{ 'some' => 'thing' }],
                   'nested' => { 'left_side' => 'left', 'right_side' => true })
        end

        it 'builds schema' do
          expect(instance.build_schema)
            .to eq(foo: 4, bar: [1, 3, 5], anything: [{ some: 'thing' }],
                   nested: { left_side: 'left', right_side: true })
        end

        it 'camelizes' do
          expect(JSON.parse(instance.surrealize(camelize: true)))
            .to eq('foo' => 4, 'bar' => [1, 3, 5], 'anything' => [{ 'some' => 'thing' }],
                   'nested' => { 'leftSide' => 'left', 'rightSide' => true })

          expect(instance.build_schema(camelize: true))
            .to eq(foo: 4, bar: [1, 3, 5], anything: [{ some: 'thing' }],
                   nested: { leftSide: 'left', rightSide: true })
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
        let(:instance) { Child.new }

        it 'surrealizes' do
          expect(JSON.parse(instance.surrealize)).to eq('foo' => 'foo', 'bar' => [1, 2])
        end

        it 'builds schema' do
          expect(instance.build_schema).to eq(foo: 'foo', bar: [1, 2])
        end
      end

      context 'with attr_readers' do
        let(:instance) { WithAttrReaders.new }

        it 'surrealizes' do
          expect(JSON.parse(instance.surrealize)).to eq('foo' => 'foo', 'bar' => [1, 2])
        end

        it 'builds schema' do
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
        let(:instance) { WithNestedObjects.new }

        it 'surrealizes & tries to invoke the method on the object' do
          expect(JSON.parse(instance.surrealize)).to eq('foo' => { 'bar_bar' => 123 })
        end

        it 'builds schema & tries to invoke the method on the object' do
          expect(instance.build_schema).to eq(foo: { bar_bar: 123 })
        end

        it 'camelizes' do
          expect(JSON.parse(instance.surrealize(camelize: true)))
            .to eq('foo' => { 'barBar' => 123 })

          expect(instance.build_schema(camelize: true)).to eq(foo: { barBar: 123 })
        end
      end

      context 'with multi-method struct' do
        let(:instance) { MultiMethodStruct.new }

        it 'surrealizes' do
          expect(JSON.parse(instance.surrealize))
            .to eq('foo' => { 'bar_bar' => 123, 'baz_baz' => 'string' })
        end

        it 'builds schema' do
          expect(instance.build_schema)
            .to eq(foo: { bar_bar: 123, baz_baz: 'string' })
        end

        it 'camelizes' do
          expect(JSON.parse(instance.surrealize(camelize: true)))
            .to eq('foo' => { 'barBar' => 123, 'bazBaz' => 'string' })

          expect(instance.build_schema(camelize: true))
            .to eq(foo: { barBar: 123, bazBaz: 'string' })
        end
      end
    end

    context 'with undefined schema' do
      let(:error) { "Can't serialize WithoutSchema - no schema was provided." }

      it 'raises error on #surrealize' do
        expect { WithoutSchema.new.surrealize }
          .to raise_error(Surrealist::UnknownSchemaError, error)

        expect { WithoutSchema.new.surrealize(camelize: true) }
          .to raise_error(Surrealist::UnknownSchemaError, error)
      end
    end
  end
end
