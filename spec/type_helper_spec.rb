# frozen_string_literal: true

require_relative '../lib/surrealist'
require 'dry-types'

module Types
  include Dry::Types.module
end

RSpec.describe Surrealist::TypeHelper do
  describe '#valid_type?' do
    context 'nil values' do
      context 'plain ruby classes' do
        [
          { value: nil, type: String },
          { value: nil, type: Integer },
          { value: nil, type: Array },
          { value: nil, type: Object },
          { value: nil, type: Any },
          { value: nil, type: Float },
          { value: nil, type: Hash },
          { value: nil, type: BigDecimal },
          { value: nil, type: Symbol },
        ].each do |params|
          it "returns true for #{params} because value is nil" do
            expect(described_class.valid_type?(params)).to eq true
          end
        end
      end

      context 'optional dry-types' do
        [
          { value: nil, type: Types::Any },
          { value: nil, type: Types::Form::Nil },
          { value: nil, type: Types::Json::Nil },
          { value: nil, type: Types::String.optional },
          { value: nil, type: Types::Int.optional },
          { value: nil, type: Types::Array.optional },
          { value: nil, type: Types::Bool.optional },
          { value: nil, type: Types::Any.optional },
          { value: nil, type: Types::Any.optional },
          { value: nil, type: Types::Symbol.optional },
          { value: nil, type: Types::Class.optional },
          { value: nil, type: Types::True.optional },
          { value: nil, type: Types::False.optional },
          { value: nil, type: Types::Float.optional },
          { value: nil, type: Types::Decimal.optional },
          { value: nil, type: Types::Hash.optional },
          { value: nil, type: Types::Date.optional },
          { value: nil, type: Types::DateTime.optional },
          { value: nil, type: Types::Time.optional },
          { value: nil, type: Types::Form::Nil.optional },
          { value: nil, type: Types::Form::Date.optional },
          { value: nil, type: Types::Form::DateTime.optional },
          { value: nil, type: Types::Form::True.optional },
          { value: nil, type: Types::Form::False.optional },
          { value: nil, type: Types::Form::Bool.optional },
          { value: nil, type: Types::Form::Int.optional },
          { value: nil, type: Types::Form::Float.optional },
          { value: nil, type: Types::Form::Decimal.optional },
          { value: nil, type: Types::Form::Array.optional },
          { value: nil, type: Types::Form::Hash.optional },
          { value: nil, type: Types::Json::Nil.optional },
          { value: nil, type: Types::Json::Date.optional },
          { value: nil, type: Types::Json::DateTime.optional },
          { value: nil, type: Types::Json::Time.optional },
          { value: nil, type: Types::Json::Decimal.optional },
          { value: nil, type: Types::Json::Array.optional },
          { value: nil, type: Types::Json::Hash.optional },
        ].each do |params|
          it "returns true for #{params} because value is nil and type is not strict" do
            expect(described_class.valid_type?(params)).to eq true
          end
        end
      end

      context 'non-optional dry-types' do
        [
          { value: nil, type: Types::String },
          { value: nil, type: Types::Int },
          { value: nil, type: Types::Array },
          { value: nil, type: Types::Bool },
          { value: nil, type: Types::Symbol },
          { value: nil, type: Types::Class },
          { value: nil, type: Types::True },
          { value: nil, type: Types::False },
          { value: nil, type: Types::Float },
          { value: nil, type: Types::Decimal },
          { value: nil, type: Types::Hash },
          { value: nil, type: Types::Date },
          { value: nil, type: Types::DateTime },
          { value: nil, type: Types::Time },
          { value: nil, type: Types::Form::Date },
          { value: nil, type: Types::Form::DateTime },
          { value: nil, type: Types::Form::True },
          { value: nil, type: Types::Form::False },
          { value: nil, type: Types::Form::Bool },
          { value: nil, type: Types::Form::Int },
          { value: nil, type: Types::Form::Float },
          { value: nil, type: Types::Form::Decimal },
          { value: nil, type: Types::Form::Array },
          { value: nil, type: Types::Form::Hash },
          { value: nil, type: Types::Json::Date },
          { value: nil, type: Types::Json::DateTime },
          { value: nil, type: Types::Json::Time },
          { value: nil, type: Types::Json::Array },
          { value: nil, type: Types::Json::Hash },
        ].each do |params|
          it "returns false for #{params} because value is nil" do
            expect(described_class.valid_type?(params)).to eq false
          end
        end
      end

      context 'strict dry-types' do
        [
          { value: nil, type: Types::Strict::Class },
          { value: nil, type: Types::Strict::True },
          { value: nil, type: Types::Strict::False },
          { value: nil, type: Types::Strict::Bool },
          { value: nil, type: Types::Strict::Int },
          { value: nil, type: Types::Strict::Float },
          { value: nil, type: Types::Strict::Decimal },
          { value: nil, type: Types::Strict::String },
          { value: nil, type: Types::Strict::Date },
          { value: nil, type: Types::Strict::DateTime },
          { value: nil, type: Types::Strict::Time },
          { value: nil, type: Types::Strict::Array },
          { value: nil, type: Types::Strict::Hash },
        ].each do |params|
          it "returns false for #{params} because value is nil & type is strict" do
            expect(described_class.valid_type?(params)).to eq false
          end
        end
      end

      context 'coercible dry-types' do
        context 'types that can be coerced from nil' do
          [
            { value: nil, type: Types::Coercible::String },
            { value: nil, type: Types::Coercible::Array },
            { value: nil, type: Types::Coercible::Hash },
          ].each do |params|
            it "returns true for #{params} because nil can be coerced" do
              expect(described_class.valid_type?(params)).to eq true
            end
          end
        end

        context 'types that can\'t be coerced' do
          [
            { value: nil, type: Types::Coercible::Int },
            { value: nil, type: Types::Coercible::Float },
            { value: nil, type: Types::Coercible::Decimal },
          ].each do |params|
            it "returns false for #{params} because nil can't be coerced" do
              expect(described_class.valid_type?(params)).to eq false
            end
          end
        end
      end
    end

    context 'string values' do
      [
        { value: 'string', type: String },
        { value: 'string', type: Types::String },
        { value: 'string', type: Types::Coercible::String },
        { value: 'string', type: Types::Strict::String },
        { value: 'string', type: Types::String.optional },
      ].each do |params|
        it "returns true for #{params}" do
          expect(described_class.valid_type?(params)).to eq true
        end
      end
    end

    context 'integer values' do
      [
        { value: 666, type: Integer },
        { value: 666, type: Types::Int },
        { value: 666, type: Types::Int.optional },
        { value: 666, type: Types::Strict::Int },
        { value: 666, type: Types::Coercible::Int },
        { value: 666, type: Types::Form::Int },
        { value: 666, type: Types::Form::Int.optional },
      ].each do |params|
        it "returns true for #{params}" do
          expect(described_class.valid_type?(params)).to eq true
        end
      end
    end

    context 'array values' do
      [
        { value: %w[an array], type: Array },
        { value: %w[an array], type: Types::Array },
        { value: %w[an array], type: Types::Array.optional },
        { value: %w[an array], type: Types::Strict::Array },
        { value: %w[an array], type: Types::Json::Array },
        { value: %w[an array], type: Types::Json::Array.optional },
        { value: %w[an array], type: Types::Form::Array },
        { value: %w[an array], type: Types::Form::Array.optional },
        { value: %w[an array], type: Types::Coercible::Array },
        { value: %w[an array], type: Types::Coercible::Array.optional },
      ].each do |params|
        it "returns true for #{params}" do
          expect(described_class.valid_type?(params)).to eq true
        end
      end
    end

    context 'hash values' do
      [
        { value: { a: :b }, type: Hash },
        { value: { a: :b }, type: Types::Hash },
        { value: { a: :b }, type: Types::Hash.optional },
        { value: { a: :b }, type: Types::Strict::Hash },
        { value: { a: :b }, type: Types::Form::Hash },
        { value: { a: :b }, type: Types::Form::Hash.optional },
        { value: { a: :b }, type: Types::Json::Hash },
        { value: { a: :b }, type: Types::Json::Hash.optional },
        { value: { a: :b }, type: Types::Coercible::Hash },
        { value: { a: :b }, type: Types::Coercible::Hash.optional },
      ].each do |params|
        it "returns true for #{params}" do
          expect(described_class.valid_type?(params)).to eq true
        end
      end
    end

    context 'any values' do
      [
        { value: nil, type: Any },
        { value: 'nil', type: Any },
        { value: :nil, type: Any },
        { value: [nil], type: Any },
        { value: { nil: :nil }, type: Any },
        { value: nil, type: Types::Any },
        { value: 'nil', type: Types::Any },
        { value: :nil, type: Types::Any },
        { value: [nil], type: Types::Any },
        { value: { nil: :nil }, type: Types::Any },
      ].each do |params|
        it "returns true for #{params}" do
          expect(described_class.valid_type?(params)).to eq true
        end
      end
    end

    context 'boolean values' do
      [
        { value: true, type: Bool },
        { value: false, type: Bool },
        { value: false, type: Types::Bool },
        { value: true, type: Types::Bool },
      ].each do |params|
        it "returns true for #{params}" do
          expect(described_class.valid_type?(params)).to eq true
        end
      end
    end

    context 'symbol values' do
      [
        { value: :sym, type: Symbol },
        { value: :sym, type: Types::Symbol },
        { value: :sym, type: Types::Symbol.optional },
        { value: :sym, type: Types::Strict::Symbol },
      ].each do |params|
        it "returns true for #{params}" do
          expect(described_class.valid_type?(params)).to eq true
        end
      end
    end
  end

  describe '#coerce' do
    [
      { value: nil, type: String },
      { value: nil, type: Integer },
      { value: nil, type: Array },
      { value: nil, type: Object },
      { value: nil, type: Any },
      { value: nil, type: Float },
      { value: nil, type: Hash },
      { value: nil, type: BigDecimal },
      { value: nil, type: Symbol },
      { value: 'something', type: String },
      { value: 'something', type: Integer },
      { value: 'something', type: Array },
      { value: 'something', type: Object },
      { value: 'something', type: Any },
      { value: 'something', type: Float },
      { value: 'something', type: Hash },
      { value: 'something', type: BigDecimal },
      { value: 'something', type: Symbol },
    ].each do |params|
      it "returns value for non-dry-types for #{params}" do
        expect(described_class.coerce(params)).to eq(params[:value])
      end
    end

    [
      { value: 'smth', type: Types::String },
      { value: 23, type: Types::Int },
      { value: [2], type: Types::Array },
      { value: true, type: Types::Bool },
      { value: :sym, type: Types::Symbol },
      { value: Array, type: Types::Class },
      { value: true, type: Types::True },
      { value: false, type: Types::False },
      { value: 2.4, type: Types::Float },
      { value: 35.4, type: Types::Decimal },
      { value: { k: :v }, type: Types::Hash },
      { value: Date.new, type: Types::Date },
      { value: DateTime.new, type: Types::DateTime },
      { value: Time.new, type: Types::Time },
      { value: Date.new, type: Types::Form::Date },
      { value: DateTime.new, type: Types::Form::DateTime },
      { value: true, type: Types::Form::True },
      { value: false, type: Types::Form::False },
      { value: true, type: Types::Form::Bool },
      { value: 3, type: Types::Form::Int },
      { value: 3.5, type: Types::Form::Float },
      { value: 56.2, type: Types::Form::Decimal },
      { value: %w[ar ray], type: Types::Form::Array },
      { value: { k: :v }, type: Types::Form::Hash },
      { value: Date.new, type: Types::Json::Date },
      { value: DateTime.new, type: Types::Json::DateTime },
      { value: Time.new, type: Types::Json::Time },
      { value: %w[ar ray], type: Types::Json::Array },
      { value: { k: :v }, type: Types::Json::Hash },
    ].each do |params|
      it "returns value if it doesn't have to be coerced for #{params}" do
        expect(described_class.coerce(params)).to eq(params[:value])
      end
    end
  end

  # Testing coercing itself is kind of pointless, because dry-types have enough specs in their repo.
end
