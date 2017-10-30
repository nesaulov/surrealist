require 'rom'
require 'rom-repository'
require 'dry-struct'
require 'surrealist'

module Types
  include Dry::Types.module
end

rom = ROM.container(:sql, 'sqlite::memory') do |conf|
  conf.default.create_table(:users) do
    primary_key :id
    column :name, String, null: false
    column :email, String, null: false
  end
end

class UserRepo < ROM::Repository[:users]
  commands :create, update: :by_pk, delete: :by_pk
end

class User < Dry::Struct
  include Surrealist

  attribute :name, String
  attribute :email, String

  json_schema { { email: String } }
end

class ROM::Struct::User < ROM::Struct
  include Surrealist

  json_schema { { name: String } }
end

RSpec.describe 'ROM Integration' do
  describe 'instance.surrealize()' do
    let(:user_repo) { UserRepo.new(rom) }
    let(:users) { user_repo.users }

    before do
      user_repo.create(name: 'Jane', email: 'jane@doe.org')
      user_repo.create(name: 'Dane', email: 'dane@doe.org')
    end

    context 'single record' do
      context 'with schema defined in ROM::Struct::Model' do
        it { expect(users.to_a.first.surrealize).to eq('{"name":"Jane"}') }
      end

      context 'using ROM::Struct::Model#as(Representative)' do
        it { expect(users.as(User).first.surrealize).to eq('{"email":"jane@doe.org"}') }
      end
    end
  end
end
