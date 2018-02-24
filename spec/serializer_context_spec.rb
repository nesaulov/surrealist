# frozen_string_literal: true

Names = Module.new do
  def user_name
    user.name
  end

  def mouse_name
    mouse.name
  end

  def cow_name
    cow.name
  end
end

TestSerializerClass = Class.new(Surrealist::Serializer) do
  prepend Names

  serializer_context :user
  json_schema { { id_num: Integer, user_name: String } }

  def id_num
    2
  end
end

Multiple = Class.new(Surrealist::Serializer) do
  prepend Names
  serializer_context :user, :mouse, :cow
  json_schema { { user_name: String, mouse_name: String, cow_name: String } }
end

Cow   = Struct.new(:name)
Mouse = Struct.new(:name)

User = Class.new do
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

Plural = Class.new(Surrealist::Serializer) do
  prepend Names
  serializer_contexts :user, :mouse, :cow
  json_schema { { user_name: String, mouse_name: String, cow_name: String } }
end

RSpec.describe Surrealist::Serializer do
  let(:user) { User.new('Dave') }
  let(:args) { { mouse: Mouse.new('Pes'), cow: Cow.new('Cat'), user: user } }

  describe '.serializer_context' do
    context 'one method' do
      let(:instance) { TestSerializerClass.new(nil, **args) }
      let(:args) { { user: user } }

      it { expect(instance.build_schema).to eq(id_num: 2, user_name: 'Dave') }
    end

    context 'many methods' do
      let(:instance) { Multiple.new(nil, **args) }

      it { expect(instance.build_schema).to eq(user_name: 'Dave', mouse_name: 'Pes', cow_name: 'Cat') }
    end

    context 'with .serializer_context defined, but context not passed' do
      let(:instance) { Multiple.new(nil) }

      it { expect { instance.build_schema }.to raise_error(Surrealist::UndefinedMethodError) }
    end

    describe 'invalid arguments' do
      ['string', nil, 2, Class, {}, []].each do |argument|
        it "raises ArgumentError for #{argument}" do
          expect do
            Class.new(Surrealist::Serializer) do
              serializer_context argument
            end
          end.to raise_error(ArgumentError, 'Please provide an array of symbols to `.serializer_context`')
        end
      end
    end
  end

  describe '.serializer_contexts' do
    context 'many methods' do
      let(:instance) { Plural.new(nil, **args) }

      it { expect(instance.build_schema).to eq(user_name: 'Dave', mouse_name: 'Pes', cow_name: 'Cat') }
    end
  end
end
