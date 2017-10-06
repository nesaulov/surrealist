# frozen_string_literal: true

require_relative '../lib/surrealist'

class Note
  include Surrealist

  json_schema do
    {
      foo:    Integer,
      bar:    Array,
      nested: {
        left:  String,
        right: Bool,
      },
    }
  end

  def foo
    4
  end

  def bar
    [1, 3, 5]
  end

  private

  def left
    'left'
  end

  def right
    true
  end

  # expecting:
  # {
  #   foo: 4, bar: [1, 3, 5], nested: {
  #     left: 'left',
  #     right: true
  #   }
  # }
end

class IncorrectTypes
  include Surrealist

  json_schema do
    { foo: Integer }
  end

  def foo
    'string'
  end

  # expecting: Surrealist::InvalidTypeError
end

class Ancestor
  private def foo
    'foo'
  end

  # expecting: see Child
end

class Infant < Ancestor
  include Surrealist

  json_schema do
    {
      foo: String,
      bar: Array,
    }
  end

  def bar
    [1, 2]
  end

  # expecting: { foo: 'foo', bar: [1, 2] }
end

class Host
  include Surrealist

  json_schema do
    { name: String }
  end

  def name
    'Parent'
  end
end

class Guest < Host
  delegate_surrealization_to Host

  def name
    'Child'
  end

  # expecting: { name: 'Child' }
end

class FriendOfGuest < Guest
  def name
    'Friend'
  end
end

class Invite < Host; end

class InvitedGuest < Invite
  delegate_surrealization_to Host

  def name
    'Invited'
  end

  # expecting: { name: 'Invited' }
end

class RandomClass
  include Surrealist

  json_schema do
    { name: String }
  end
end

class DifferentClass
  include Surrealist

  delegate_surrealization_to RandomClass

  def name
    'smth'
  end

  # expecting: { name: 'smth' }
end

RSpec.describe Surrealist do
  describe '#build_schema' do
    context 'with defined schema' do
      context 'with correct types' do
        it 'works' do
          expect(Note.new.build_schema).to eq(foo: 4, bar: [1, 3, 5], nested: {
            left: 'left', right: true
          })
        end
      end

      context 'with wrong types' do
        it 'raises TypeError' do
          expect { IncorrectTypes.new.build_schema }
            .to raise_error(Surrealist::InvalidTypeError,
                            'Wrong type for key `foo`. Expected Integer, got String.')
        end
      end
      context 'with inheritance' do
        it 'works' do
          expect(Infant.new.build_schema).to eq(foo: 'foo', bar: [1, 2])
        end
      end
    end
    context 'with delegated schema' do
      it 'works' do
        expect(Guest.new.build_schema).to eq(name: 'Child')
      end

      context 'inheritance of class that has delegated but we don\'t delegate' do
        it 'raises RuntimeError' do
          expect { FriendOfGuest.new.build_schema }
            .to raise_error(Surrealist::UnknownSchemaError,
              "Can't serialize FriendOfGuest - no schema was provided.")
        end
      end

      context 'inheritance of class that has not delegated but we delegate' do
        it 'uses current delegation' do
          expect(InvitedGuest.new.build_schema).to eq(name: 'Invited')
        end
      end

      context 'with invalid ancestor' do
        it 'raises RuntimeError' do
          expect { eval 'class IncorrectGuest < Host
                           delegate_surrealization_to Integer
                         end' }
            .to raise_error(Surrealist::InvalidSchemaDelegation,
                            'Class does not include Surrealist')
        end
      end

      context 'with invalid arguement type' do
        it 'raises TypeError' do
          expect { eval "class InvalidGuest < Host
                           delegate_surrealization_to 'InvalidHost'
                         end" }
            .to raise_error(TypeError,
                            'Expected type of Class got String instead')
        end
      end

      context 'with unrelated class' do
        it 'works' do
          expect(DifferentClass.new.build_schema).to eq(name: 'smth')
        end
      end
    end
  end
end
