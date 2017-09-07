# frozen_string_literal: true

require 'json'
require_relative '../lib/surrealist'

class Baz
  include Surrealist

  schema do
    {
      foo: Integer,
      bar: Array,
      nested:  {
        left:  String,
        right: Boolean,
      },
    }
  end

  def foo; 4; end

  def bar; [1, 3, 5]; end

  private

  def left; 'left'; end

  def right; true; end
end

class WrongTypes
  include Surrealist

  schema do
    { foo: Integer }
  end

  def foo; 'string'; end
end

class WithoutSchema
  include Surrealist
  def foo; 4; end

  def bar; 9 * 3; end

  def baz; 1; end
end

class Parent
  private def foo
    'foo'
  end
end

class Child < Parent
  include Surrealist

  schema do
    {
      foo: String,
      bar: Array,
    }
  end

  def bar; [1, 2]; end
end

class WithAttrReaders
  include Surrealist

  attr_reader :foo, :bar

  schema do
    {
      foo: String,
      bar: Array,
    }
  end

  def initialize
    @foo = 'foo'
    @bar = [1, 2]
  end
end

class WithNil
  include Surrealist

  schema do
    { foo: NilClass }
  end

  def foo; end
end

RSpec.describe 'Surrealist' do
  context 'with defined schema' do
    context 'with correct types' do
      it 'works' do
        expect(JSON.parse(Baz.new.surrealize))
          .to eq('foo' => 4, 'bar' => [1, 3, 5], 'nested' => {
            'left'  => 'left',
            'right' => true,
          })
      end
    end

    context 'with wrong types' do
      it 'raises TypeError' do
        expect { WrongTypes.new.surrealize }
          .to raise_error(Surrealist::InvalidTypeError,
                          'Wrong type for key `foo`. Expected Integer, got String.')
      end
    end

    context 'with inheritance' do
      it 'works' do
        expect(JSON.parse(Child.new.surrealize)).to eq('foo' => 'foo', 'bar' => [1, 2])
      end
    end

    context 'with attr_readers' do
      it 'works' do
        expect(JSON.parse(WithAttrReaders.new.surrealize)).to eq('foo' => 'foo', 'bar' => [1, 2])
      end
    end

    context 'with NilClass' do
      it 'works' do
        expect(JSON.parse(WithNil.new.surrealize)).to eq('foo' => nil)
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
