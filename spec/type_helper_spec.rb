# frozen_string_literal: true

RSpec.describe Surrealist::TypeHelper do
  describe '#valid_type?' do
    context 'nil values' do
      context 'plain ruby classes' do
        [
          [nil, String],
          [nil, Integer],
          [nil, Array],
          [nil, Object],
          [nil, Any],
          [nil, Float],
          [nil, Hash],
          [nil, BigDecimal],
          [nil, Symbol],
        ].each do |params|
          it "returns true for #{params} because value is nil" do
            expect(described_class.valid_type?(*params)).to eq true
          end
        end
      end

      context 'optional dry-types' do
        [
          [nil, Types::Any],
          [nil, Types::JSON::Nil],
          [nil, Types::String.optional],
          [nil, Types::Integer.optional],
          [nil, Types::Array.optional],
          [nil, Types::Bool.optional],
          [nil, Types::Any.optional],
          [nil, Types::Any.optional],
          [nil, Types::Symbol.optional],
          [nil, Types::Class.optional],
          [nil, Types::True.optional],
          [nil, Types::False.optional],
          [nil, Types::Float.optional],
          [nil, Types::Decimal.optional],
          [nil, Types::Hash.optional],
          [nil, Types::Date.optional],
          [nil, Types::DateTime.optional],
          [nil, Types::Time.optional],
          [nil, Types::JSON::Nil.optional],
          [nil, Types::JSON::Date.optional],
          [nil, Types::JSON::DateTime.optional],
          [nil, Types::JSON::Time.optional],
          [nil, Types::JSON::Decimal.optional],
          [nil, Types::JSON::Array.optional],
          [nil, Types::JSON::Hash.optional],
        ].each do |params|
          it "returns true for #{params} because value is nil and type is not strict" do
            expect(described_class.valid_type?(*params)).to eq true
          end
        end
      end

      context 'non-optional dry-types' do
        [
          [nil, Types::String],
          [nil, Types::Integer],
          [nil, Types::Array],
          [nil, Types::Bool],
          [nil, Types::Symbol],
          [nil, Types::Class],
          [nil, Types::True],
          [nil, Types::False],
          [nil, Types::Float],
          [nil, Types::Decimal],
          [nil, Types::Hash],
          [nil, Types::Date],
          [nil, Types::DateTime],
          [nil, Types::Time],
          [nil, Types::JSON::Date],
          [nil, Types::JSON::DateTime],
          [nil, Types::JSON::Time],
          [nil, Types::JSON::Array],
          [nil, Types::JSON::Hash],
        ].each do |params|
          it "returns false for #{params} because value is nil" do
            expect(described_class.valid_type?(*params)).to eq false
          end
        end
      end

      context 'strict dry-types' do
        [
          [nil, Types::Strict::Class],
          [nil, Types::Strict::True],
          [nil, Types::Strict::False],
          [nil, Types::Strict::Bool],
          [nil, Types::Strict::Integer],
          [nil, Types::Strict::Float],
          [nil, Types::Strict::Decimal],
          [nil, Types::Strict::String],
          [nil, Types::Strict::Date],
          [nil, Types::Strict::DateTime],
          [nil, Types::Strict::Time],
          [nil, Types::Strict::Array],
          [nil, Types::Strict::Hash],
        ].each do |params|
          it "returns false for #{params} because value is nil & type is strict" do
            expect(described_class.valid_type?(*params)).to eq false
          end
        end
      end

      context 'coercible dry-types' do
        context 'types that can be coerced from nil' do
          [
            [nil, Types::Coercible::String],
            [nil, Types::Coercible::Array],
            [nil, Types::Coercible::Hash],
          ].each do |params|
            it "returns true for #{params} because nil can be coerced" do
              expect(described_class.valid_type?(*params)).to eq true
            end
          end
        end

        context 'types that can\'t be coerced' do
          [
            [nil, Types::Coercible::Integer],
            [nil, Types::Coercible::Float],
            [nil, Types::Coercible::Decimal],
          ].each do |params|
            it "returns false for #{params} because nil can't be coerced" do
              expect(described_class.valid_type?(*params)).to eq false
            end
          end
        end
      end
    end

    context 'string values' do
      [
        ['string', String],
        ['string', Types::String],
        ['string', Types::Coercible::String],
        ['string', Types::Strict::String],
        ['string', Types::String.optional],
      ].each do |params|
        it "returns true for #{params}" do
          expect(described_class.valid_type?(*params)).to eq true
        end
      end
    end

    context 'integer values' do
      [
        [666, Integer],
        [666, Types::Integer],
        [666, Types::Integer.optional],
        [666, Types::Strict::Integer],
        [666, Types::Coercible::Integer],
      ].each do |params|
        it "returns true for #{params}" do
          expect(described_class.valid_type?(*params)).to eq true
        end
      end
    end

    context 'array values' do
      [
        [%w[an array], Array],
        [%w[an array], Types::Array],
        [%w[an array], Types::Array.optional],
        [%w[an array], Types::Strict::Array],
        [%w[an array], Types::JSON::Array],
        [%w[an array], Types::JSON::Array.optional],
        [%w[an array], Types::Coercible::Array],
        [%w[an array], Types::Coercible::Array.optional],
      ].each do |params|
        it "returns true for #{params}" do
          expect(described_class.valid_type?(*params)).to eq true
        end
      end
    end

    context 'hash values' do
      [
        [{ a: :b }, Hash],
        [{ a: :b }, Types::Hash],
        [{ a: :b }, Types::Hash.optional],
        [{ a: :b }, Types::Strict::Hash],
        [{ a: :b }, Types::JSON::Hash],
        [{ a: :b }, Types::JSON::Hash.optional],
        [{ a: :b }, Types::Coercible::Hash],
        [{ a: :b }, Types::Coercible::Hash.optional],
      ].each do |params|
        it "returns true for #{params}" do
          expect(described_class.valid_type?(*params)).to eq true
        end
      end
    end

    context 'any values' do
      [
        [nil, Any],
        ['nil', Any],
        [:nil, Any],
        [[nil], Any],
        [{ nil: :nil }, Any],
        [nil, Types::Any],
        ['nil', Types::Any],
        [:nil, Types::Any],
        [[nil], Types::Any],
        [{ nil: :nil }, Types::Any],
      ].each do |params|
        it "returns true for #{params}" do
          expect(described_class.valid_type?(*params)).to eq true
        end
      end
    end

    context 'boolean values' do
      [
        [true, Bool],
        [false, Bool],
        [false, Types::Bool],
        [true, Types::Bool],
        [nil, Bool],
      ].each do |params|
        it "returns true for #{params}" do
          expect(described_class.valid_type?(*params)).to eq true
        end
      end
    end

    context 'symbol values' do
      [
        [:sym, Symbol],
        [:sym, Types::Symbol],
        [:sym, Types::Symbol.optional],
        [:sym, Types::Strict::Symbol],
      ].each do |params|
        it "returns true for #{params}" do
          expect(described_class.valid_type?(*params)).to eq true
        end
      end
    end
  end

  describe '#coerce' do
    [
      [nil, String],
      [nil, Integer],
      [nil, Array],
      [nil, Object],
      [nil, Any],
      [nil, Float],
      [nil, Hash],
      [nil, BigDecimal],
      [nil, Symbol],
      ['something', String],
      ['something', Integer],
      ['something', Array],
      ['something', Object],
      ['something', Any],
      ['something', Float],
      ['something', Hash],
      ['something', BigDecimal],
      ['something', Symbol],
    ].each do |params|
      it "returns value for non-dry-types for #{params}" do
        expect(described_class.coerce(*params)).to eq(params.first)
      end
    end

    [
      ['smth', Types::String],
      [23, Types::Integer],
      [[2], Types::Array],
      [true, Types::Bool],
      [:sym, Types::Symbol],
      [Array, Types::Class],
      [true, Types::True],
      [false, Types::False],
      [2.4, Types::Float],
      [35.4, Types::Decimal],
      [{ k: :v }, Types::Hash],
      [Date.new, Types::Date],
      [DateTime.new, Types::DateTime],
      [Time.new, Types::Time],
      [Date.new, Types::JSON::Date],
      [DateTime.new, Types::JSON::DateTime],
      [Time.new, Types::JSON::Time],
      [%w[ar ray], Types::JSON::Array],
      [{ k: :v }, Types::JSON::Hash],
    ].each do |params|
      it "returns value if it doesn't have to be coerced for #{params}" do
        expect(described_class.coerce(*params)).to eq(params.first)
      end
    end
  end

  # Testing coercing itself is kind of pointless, because dry-types have enough specs in their repo.
end
