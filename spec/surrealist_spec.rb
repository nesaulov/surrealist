# frozen_string_literal: true

require 'pry'
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

class Foo
  include Surrealist

  schema do
    { foo: Integer }
  end

  def foo; 'string'; end
end

class Wrong
  include Surrealist
  def foo; 4; end

  def bar; 9 * 3; end

  def baz; 1; end
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
        expect { Foo.new.surrealize }
          .to raise_error(TypeError, 'Wrong type for key `foo`. Expected Integer, got String')
      end
    end
  end

  context 'with undefined schema' do
    it 'raises error on #surrealize' do
      expect { Wrong.new.surrealize }
        .to raise_error(Surrealist::UnknownSchemaError, "Can't serialize Wrong - no schema was provided.")
    end
  end
end
