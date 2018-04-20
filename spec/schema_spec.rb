class WithSchema
  include Surrealist

  json_schema { { name: String, age: Integer } }

  def name
    'John'
  end

  def age
    21
  end
end

class WithoutSchema
  include Surrealist
end

class PersonSerializer < Surrealist::Serializer
  json_schema { { age: Integer } }

  def age
    20
  end
end

class WithCustomSerializer
  include Surrealist
  attr_reader :age

  surrealize_with PersonSerializer

  def initialize(age)
    @age = age
  end
end

RSpec.describe Surrealist do
  describe '.defined_schema' do
    context 'json schema defined' do
      context 'using custom serializer' do
        it 'returns the defined json_schema' do
          expect(PersonSerializer.defined_schema).to eq(age: Integer)
          expect(WithCustomSerializer.defined_schema).to eq(age: Integer)
        end
      end

      context 'not using custom serializer' do
        it 'returns the defined json_schema' do
          expect(WithSchema.defined_schema).to eq(name: String, age: Integer)
        end
      end
    end

    context 'json schema not defined' do
      it 'raises UnknownSchemaError' do
        expect { WithoutSchema.defined_schema }.to raise_error(Surrealist::UnknownSchemaError)
      end
    end
  end
end
