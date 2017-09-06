# frozen_string_literal: true

require_relative '../lib/schemeson'
require 'json'
require 'pry'

class Basic
  include Schemeson

  builds %i[foo bar]

  def foo; 4; end
  def bar; 9; end
  def baz; 1; end
end

class Wrong
  include Schemeson

  def foo; 4; end
  def bar; 9; end
  def baz; 1; end
end

class WithPrivate
  include Schemeson

  builds %i[foo bar]

  def foo; 4; end

  private def bar; 9; end
end

RSpec.describe 'Schemeson' do
  context 'with `builds`' do
    context 'with private methods' do
      it 'works' do
        expect(JSON.parse(WithPrivate.new.serialize)).to eq('foo' => 4, 'bar' => 9)
      end
    end

    context 'with public methods' do
      it 'works' do
        expect(JSON.parse(Basic.new.serialize)).to eq('foo' => 4, 'bar' => 9)
      end
    end
  end

  context 'without `builds`' do
    it 'raises error on #serialize' do
      expect { Wrong.new.serialize }
        .to raise_error(Schemeson::UnknownSchemaError, "Can't serialize Wrong - no schema was provided.")
    end

    it 'does not affect default object behaviour' do
      expect { Wrong.new.bar }.not_to raise_error
    end
  end
end
