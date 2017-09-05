# frozen_string_literal: true

class Foo
  def height
    2 * 4
  end
end

class Baz
  def foo
    'bar'
  end

  def bar
    { a: 5 }
  end
end

class WithBuild
  def schemeson_build
    %i[foo bar]
  end

  def foo
    'bar'
  end

  def bar
    { a: 5 }
  end

  def baz
    'baz'
  end
end

class Schemeson
  def initialize(instance)
    @instance = instance
    @necessary_attributes = instance.schemeson_build rescue nil
  end

  def build_schema
    methods = @necessary_attributes.nil? ? @instance.class.instance_methods(false) : @necessary_attributes
    methods.each_with_object({}) do |method, hash|
      hash[method] = @instance.send(method)
    end
  end
end

RSpec.describe 'Schemeson' do
  let(:schemeson) { Schemeson.new(instance) }

  context 'with one method' do
    let(:instance) { Foo.new }

    it 'works' do
      expect(schemeson.build_schema).to eq(height: 8)
    end
  end

  context 'with many methods' do
    let(:instance) { Baz.new }

    it 'works' do
      expect(schemeson.build_schema).to eq(foo: 'bar', bar: { a: 5 })
    end
  end

  context 'with schemeson build' do
    let(:instance) { WithBuild.new }

    it 'works' do
      expect(schemeson.build_schema).to eq(foo: 'bar', bar: { a: 5 })
    end
  end
end
