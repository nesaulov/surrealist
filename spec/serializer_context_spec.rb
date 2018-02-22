# frozen_string_literal: true

require_relative '../lib/surrealist'

TestSerializerClass = Class.new(Surrealist::Serializer) do
  serializer_context :user
  json_schema { { id_num: Integer, user_name: String } }

  def id_num
    2
  end

  def user_name
    user.name
  end
end

Multiple = Class.new(Surrealist::Serializer) do
  serializer_context :user, :mouse, nil, :cow
  json_schema { { user_name: String, mouse_name: String, cow_name: String } }

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

Cow   = Struct.new(:name)
Mouse = Struct.new(:name)

User = Class.new do
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

RSpec.describe Surrealist::Serializer do
  describe '.serializer_context' do
    let(:user) { User.new('Dave') }

    context 'one method' do
      let(:instance) { TestSerializerClass.new(nil, **args) }
      let(:args) { { user: user } }

      it { expect(instance.build_schema).to eq(id_num: 2, user_name: 'Dave') }
    end

    context 'many methods' do
      let(:instance) { Multiple.new(nil, **args) }
      let(:args) { { mouse: Mouse.new('Pes'), cow: Cow.new('Cat'), user: user } }

      it { expect(instance.build_schema).to eq(user_name: 'Dave', mouse_name: 'Pes', cow_name: 'Cat') }
    end
  end
end
