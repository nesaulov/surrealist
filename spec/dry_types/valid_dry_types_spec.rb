# frozen_string_literal: true

require 'date'

class ExampleClass; end

class ValidWithBaseTypes
  include Surrealist

  json_schema do
    {
      an_any: Types::Any,
      a_nil: Types::Nil,
      a_symbol: Types::Symbol,
      a_class: Types::Class,
      a_true: Types::True,
      a_false: Types::False,
      a_bool: Types::Bool,
      an_int: Types::Integer,
      a_float: Types::Float,
      a_decimal: Types::Decimal,
      a_string: Types::String,
      an_array: Types::Array,
      a_hash: Types::Hash,
      times: {
        a_date: Types::Date,
        a_date_time: Types::DateTime,
        a_time: Types::Time,
      },
    }
  end

  def an_any; 'smth'; end
  def a_nil; end
  def a_symbol; :a; end
  def a_class; ExampleClass; end
  def a_true; true; end
  def a_false; false; end
  def a_bool; true; end
  def an_int; 42; end
  def a_float; 42.5; end
  def a_decimal; BigDecimal(23); end
  def a_string; 'string'; end
  def a_date; Date.new(42); end
  def a_date_time; DateTime.new(42); end
  def a_time; Time.new(42); end
  def an_array; [1, 2, 3]; end
  def a_hash; { key: :value }; end
end

class ValidWithStrictTypes
  include Surrealist

  json_schema do
    {
      a_nil: Types::Strict::Nil,
      a_symbol: Types::Strict::Symbol,
      a_class: Types::Strict::Class,
      a_true: Types::Strict::True,
      a_false: Types::Strict::False,
      a_bool: Types::Strict::Bool,
      an_int: Types::Strict::Integer,
      a_float: Types::Strict::Float,
      a_decimal: Types::Strict::Decimal,
      a_string: Types::Strict::String,
      an_array: Types::Strict::Array,
      a_hash: Types::Strict::Hash,
      times: {
        a_date: Types::Strict::Date,
        a_date_time: Types::Strict::DateTime,
        a_time: Types::Strict::Time,
      },
    }
  end

  def a_nil; end
  def a_symbol; :a; end
  def a_class; ExampleClass; end
  def a_true; true; end
  def a_false; false; end
  def a_bool; true; end
  def an_int; 42; end
  def a_float; 42.5; end
  def a_decimal; BigDecimal(23); end
  def a_string; 'string'; end
  def a_date; Date.new(42); end
  def a_date_time; DateTime.new(42); end
  def a_time; Time.new(42); end
  def an_array; [1, 2, 3]; end
  def a_hash; { key: :value }; end
end

class WithValidCoercibleTypes
  include Surrealist

  json_schema do
    {
      a_string: Types::Coercible::String,
      an_int: Types::Coercible::Integer,
      a_float: Types::Coercible::Float,
      a_decimal: Types::Coercible::Decimal,
      an_array: Types::Coercible::Array,
      a_hash: Types::Coercible::Hash,
    }
  end

  def a_string; 42; end
  def an_int; '42'; end
  def a_float; '43.6'; end
  def a_decimal; BigDecimal('23'); end
  def an_array; '[1, 2, 3]'; end
  def a_hash; []; end
end

class WithValidJsonTypes
  include Surrealist

  json_schema do
    {
      a_nil: Types::JSON::Nil,
      a_date: Types::JSON::Date,
      a_date_time: Types::JSON::DateTime,
      a_time: Types::JSON::Time,
      a_decimal: Types::JSON::Decimal,
      an_array: Types::JSON::Array,
      a_hash: Types::JSON::Hash,
    }
  end

  def a_nil; nil; end
  def a_date; Date.new(42); end
  def a_date_time; DateTime.new(42); end
  def a_time; Time.new(42); end
  def a_decimal; BigDecimal(23); end
  def an_array; []; end
  def a_hash; {}; end
end

class WithValidOptionalAndConstrained
  include Surrealist

  json_schema do
    {
      a_string: Types::String.optional,
      an_int: Types::Strict::Integer.constrained(gteq: 18),
    }
  end

  def a_string; end
  def an_int; 32; end
end

RSpec.describe 'Dry-types with valid scenarios' do
  context 'with base types' do
    let(:instance) { ValidWithBaseTypes.new }

    it 'builds schema' do
      expect(instance.build_schema)
        .to eq(an_any: 'smth', a_nil: nil, a_symbol: :a, a_class: ExampleClass,
               a_true: true, a_false: false, a_bool: true, an_int: 42, a_float: 42.5,
               a_decimal: 23, a_string: 'string', an_array: [1, 2, 3], a_hash: { key: :value },
               times: {
                 a_date: Date.new(42), a_date_time: DateTime.new(42),
                 a_time: Time.new(42)
               })
    end

    it 'surrealizes' do
      expect(JSON.parse(instance.surrealize))
        .to eq('an_any' => 'smth', 'a_nil' => nil, 'a_symbol' => 'a', 'a_class' => 'ExampleClass',
               'a_true' => true, 'a_false' => false, 'a_bool' => true, 'an_int' => 42,
               'a_float' => 42.5, 'a_decimal' => BigDecimal(23).to_s, 'a_string' => 'string',
               'an_array' => [1, 2, 3], 'a_hash' => { 'key' => 'value' }, 'times' => {
                 'a_date' => Date.new(42).to_s, 'a_date_time' => DateTime.new(42).strftime('%FT%T.%L%:z'),
                 'a_time' => Time.new(42).strftime('%FT%T.%L%:z')
               })
    end

    it 'camelizes' do
      expect(instance.build_schema(camelize: true))
        .to eq(anAny: 'smth', aNil: nil, aSymbol: :a, aClass: ExampleClass,
               aTrue: true, aFalse: false, aBool: true, anInt: 42, aFloat: 42.5,
               aDecimal: 23, aString: 'string', anArray: [1, 2, 3], aHash: { key: :value },
               times: {
                 aDate: Date.new(42), aDateTime: DateTime.new(42),
                 aTime: Time.new(42)
               })

      expect(JSON.parse(instance.surrealize(camelize: true)))
        .to eq('anAny' => 'smth', 'aNil' => nil, 'aSymbol' => 'a', 'aClass' => 'ExampleClass',
               'aTrue' => true, 'aFalse' => false, 'aBool' => true, 'anInt' => 42,
               'aFloat' => 42.5, 'aDecimal' => BigDecimal(23).to_s, 'aString' => 'string',
               'anArray' => [1, 2, 3], 'aHash' => { 'key' => 'value' }, 'times' => {
                 'aDate' => Date.new(42).to_s, 'aDateTime' => DateTime.new(42).strftime('%FT%T.%L%:z'),
                 'aTime' => Time.new(42).strftime('%FT%T.%L%:z')
               })
    end
  end

  context 'with strict types' do
    let(:instance) { ValidWithStrictTypes.new }

    it 'builds schema' do
      expect(instance.build_schema)
        .to eq(a_nil: nil, a_symbol: :a, a_class: ExampleClass, a_true: true, a_false: false,
               a_bool: true, an_int: 42, a_float: 42.5, a_decimal: 23, a_string: 'string',
               an_array: [1, 2, 3], a_hash: { key: :value }, times: {
                 a_date: Date.new(42), a_date_time: DateTime.new(42),
                 a_time: Time.new(42)
               })
    end

    it 'surrealizes' do
      expect(JSON.parse(instance.surrealize))
        .to eq('a_nil' => nil, 'a_symbol' => 'a', 'a_class' => 'ExampleClass',
               'a_true' => true, 'a_false' => false, 'a_bool' => true, 'an_int' => 42,
               'a_float' => 42.5, 'a_decimal' => BigDecimal(23).to_s, 'a_string' => 'string',
               'an_array' => [1, 2, 3], 'a_hash' => { 'key' => 'value' }, 'times' => {
                 'a_date' => Date.new(42).to_s,
                 'a_date_time' => DateTime.new(42).strftime('%FT%T.%L%:z'),
                 'a_time' => Time.new(42).strftime('%FT%T.%L%:z'),
               })
    end

    it 'camelizes' do
      expect(instance.build_schema(camelize: true))
        .to eq(aNil: nil, aSymbol: :a, aClass: ExampleClass, aTrue: true, aFalse: false,
               aBool: true, anInt: 42, aFloat: 42.5, aDecimal: 23, aString: 'string',
               anArray: [1, 2, 3], aHash: { key: :value }, times: {
                 aDate: Date.new(42), aDateTime: DateTime.new(42),
                 aTime: Time.new(42)
               })

      expect(JSON.parse(instance.surrealize(camelize: true)))
        .to eq('aNil' => nil, 'aSymbol' => 'a', 'aClass' => 'ExampleClass',
               'aTrue' => true, 'aFalse' => false, 'aBool' => true, 'anInt' => 42,
               'aFloat' => 42.5, 'aDecimal' => BigDecimal(23).to_s, 'aString' => 'string',
               'anArray' => [1, 2, 3], 'aHash' => { 'key' => 'value' }, 'times' => {
                 'aDate' => Date.new(42).to_s, 'aDateTime' => DateTime.new(42).strftime('%FT%T.%L%:z'),
                 'aTime' => Time.new(42).strftime('%FT%T.%L%:z')
               })
    end
  end

  context 'with coercible types' do
    let(:instance) { WithValidCoercibleTypes.new }

    it 'builds schema' do
      expect(instance.build_schema)
        .to eq(a_string: '42', an_int: 42, a_float: 43.6, a_decimal: BigDecimal(23),
               an_array: ['[1, 2, 3]'], a_hash: {})
    end

    it 'surrealizes' do
      expect(JSON.parse(instance.surrealize))
        .to eq('a_string' => '42', 'an_int' => 42, 'a_float' => 43.6,
               'a_decimal' => BigDecimal(23).to_s, 'an_array' => ['[1, 2, 3]'], 'a_hash' => {})
    end

    it 'camelizes' do
      expect(instance.build_schema(camelize: true))
        .to eq(aString: '42', anInt: 42, aFloat: 43.6, aDecimal: BigDecimal(23),
               anArray: ['[1, 2, 3]'], aHash: {})

      expect(JSON.parse(instance.surrealize(camelize: true)))
        .to eq('aString' => '42', 'anInt' => 42, 'aFloat' => 43.6,
               'aDecimal' => BigDecimal(23).to_s, 'anArray' => ['[1, 2, 3]'], 'aHash' => {})
    end
  end

  context 'with json types' do
    let(:instance) { WithValidJsonTypes.new }

    it 'builds schema' do
      expect(instance.build_schema)
        .to eq(a_nil: nil, a_date: Date.new(42), a_date_time: DateTime.new(42),
               a_time: Time.new(42), a_decimal: BigDecimal(23), an_array: [], a_hash: {})
    end

    it 'surrealizes' do
      expect(JSON.parse(instance.surrealize))
        .to eq('a_nil' => nil, 'a_date' => Date.new(42).to_s,
               'a_date_time' => DateTime.new(42).strftime('%FT%T.%L%:z'),
               'a_time' => Time.new(42).strftime('%FT%T.%L%:z'), 'a_decimal' => BigDecimal(23).to_s,
               'an_array' => [], 'a_hash' => {})
    end

    it 'camelizes' do
      expect(instance.build_schema(camelize: true))
        .to eq(aNil: nil, aDate: Date.new(42), aDateTime: DateTime.new(42),
               aTime: Time.new(42), aDecimal: BigDecimal(23), anArray: [], aHash: {})

      expect(JSON.parse(instance.surrealize(camelize: true)))
        .to eq('aNil' => nil, 'aDate' => Date.new(42).to_s,
               'aDateTime' => DateTime.new(42).strftime('%FT%T.%L%:z'),
               'aTime' => Time.new(42).strftime('%FT%T.%L%:z'), 'aDecimal' => BigDecimal(23).to_s,
               'anArray' => [], 'aHash' => {})
    end
  end

  context 'with optional & constrained types' do
    let(:instance) { WithValidOptionalAndConstrained.new }

    it 'builds schema' do
      expect(instance.build_schema).to eq(a_string: nil, an_int: 32)
    end

    it 'surrealizes' do
      expect(JSON.parse(instance.surrealize)).to eq('a_string' => nil, 'an_int' => 32)
    end

    it 'camelizes' do
      expect(instance.build_schema(camelize: true)).to eq(aString: nil, anInt: 32)
      expect(JSON.parse(instance.surrealize(camelize: true))).to eq('aString' => nil, 'anInt' => 32)
    end
  end
end
