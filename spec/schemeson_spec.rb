# frozen_string_literal: true

require_relative '../lib/schemeson'

class Baz
  include Schemeson

  builds %i[foo bar]

  def foo; 4; end
  def bar; 9; end
  def baz; 1; end
end

RSpec.describe 'Schemeson' do
  it 'works' do
    expect(Baz.new.serialize).to eq(foo: 4, bar: 9)
  end
end
