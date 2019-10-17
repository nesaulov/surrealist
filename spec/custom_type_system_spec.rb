# frozen_string_literal: true

require 'thy'

RSpec.describe 'custom type system' do
  before do
    stub_const('ThyTypeSystem', Module.new do
      class << self
        include Surrealist::Result::DSL

        def check_type(value, type_class)
          result = type_class.check(value)

          return success if result.success?

          failure(result.message)
        end

        # Does not support coercion
        def coerce(value, _type_class)
          value
        end
      end
    end)

    Surrealist.configure { |c| c.type_system = ThyTypeSystem }
  end

  class ThyCowSerializer < Surrealist::Serializer
    json_schema do
      {
        milky: Thy::Boolean,
        is_adult: Thy::Boolean,
        age: Thy::Integer,
        gender: Thy::Enum('male', 'female'),
      }
    end
  end

  let(:cow_class) { Struct.new(:milky, :is_adult, :age, :gender) }

  context 'valid parameters' do
    let(:cow) { cow_class.new(false, false, 12, 'male') }

    it 'serializes successfully' do
      expect(ThyCowSerializer.new(cow).build_schema).to eq(
        milky: false,
        is_adult: false,
        age: 12,
        gender: 'male',
      )
    end
  end

  context 'invalid parameters' do
    let(:cow) { cow_class.new(true, true, 69, nil) }

    it 'fails to serialize and displays a system-specific error message' do
      expect { ThyCowSerializer.new(cow).build_schema }.to raise_error(
        Surrealist::InvalidTypeError,
        'Wrong type for key `gender`. Expected nil to be one of: ["male", "female"].',
      )
    end
  end
end
