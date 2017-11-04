# frozen_string_literal: true

class UserModel
  include Surrealist

  json_schema { { email: String } }

  attr_reader :id, :name, :email

  def initialize(attributes)
    @id, @name, @email = attributes.values_at(:id, :name, :email)
  end
end

class UsersMapper < ROM::Mapper
  register_as :user_obj
  relation :users
  model UserModel
end

container = ROM.container(:sql, ['sqlite::memory']) do |conf|
  conf.default.create_table(:users) do
    primary_key :id
    column :name, String, null: false
    column :email, String, null: false
  end

  conf.register_mapper(UsersMapper)
  conf.commands(:users) do
    define(:create)
  end
end

class UserRepo < ROM::Repository[:users]
  commands :create, update: :by_pk, delete: :by_pk
end

class RomUser < Dry::Struct
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
    let(:user_repo) { UserRepo.new(container) }
    let(:users) { user_repo.users }

    context 'single record' do
      before(:all) do
        user_repo = UserRepo.new(container)
        [
          { name: 'Jane Struct', email: 'jane@struct.rom' },
          { name: 'Dane As', email: 'dane@as.rom' },
          { name: 'Jack Mapper', email: 'jack@mapper.rom' },
        ].each { |user| user_repo.create(user) }
      end

      context 'with schema defined in ROM::Struct::Model' do
        let(:instance) { users.to_a.first }

        it { expect(instance.surrealize).to eq('{"name":"Jane Struct"}') }
        it_behaves_like 'error is not raised for valid params: instance'
        it_behaves_like 'error is raised for invalid params: instance'
      end

      context 'using ROM::Struct::Model#as(Representative)' do
        let(:instance) { users.as(RomUser).to_a[1] }

        it { expect(instance.surrealize).to eq('{"email":"dane@as.rom"}') }
        it_behaves_like 'error is not raised for valid params: instance'
        it_behaves_like 'error is raised for invalid params: instance'
      end

      context 'using mapper' do
        let(:instance) { users.as(:user_obj).to_a[2] }

        it { expect(instance.surrealize).to eq('{"email":"jack@mapper.rom"}') }
        it { expect(users.as(:user_obj).to_a.size).to eq(3) }
        it_behaves_like 'error is not raised for valid params: instance'
        it_behaves_like 'error is raised for invalid params: instance'
      end
    end
  end
end
