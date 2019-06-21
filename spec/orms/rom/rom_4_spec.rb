# frozen_string_literal: true

unless ruby_24
  class UserModel
    include Surrealist

    json_schema { { id: Integer, email: String } }

    attr_reader :id, :name, :email

    def initialize(attributes)
      @id = attributes[:id]
      @name = attributes[:name]
      @email = attributes[:email]
    end
  end

  class UsersMapper < ROM::Mapper
    register_as :user_obj
    relation :users
    model UserModel
  end

  class SchemalessUser
    include Surrealist

    attr_reader :id, :name, :email

    def initialize(attributes)
      @id = attributes.id
      @name = attributes.name
      @email = attributes.email
    end
  end

  class SomeUser
    include Surrealist

    json_schema { { id: Integer, email: String } }

    attr_reader :id, :name, :email

    def initialize(attributes)
      @id = attributes.id
      @name = attributes.name
      @email = attributes.email
    end
  end

  class DelegatedUser < SomeUser
    delegate_surrealization_to SomeUser

    def initialize(attributes)
      super
      @email = 'delegated@example.com'
    end
  end

  class GrandChildUser < DelegatedUser
  end

  class MapperWithoutSchema < ROM::Mapper
    register_as :user_wo_schema
    relation :users
    model SchemalessUser
  end

  class MapperDelegatedSchema < ROM::Mapper
    register_as :user_de_schema
    relation :users
    model DelegatedUser
  end

  class MapperInheritedDelegatedSchema < ROM::Mapper
    register_as :user_child_de_schema
    relation :users
    model GrandChildUser
  end

  container = ROM.container(:sql, 'sqlite::memory') do |config|
    config.default.connection.create_table(:users) do
      primary_key :id
      column :name, String, null: false
      column :email, String, null: false
    end

    config.relation(:users) do
      schema(infer: true)
      auto_map false
    end

    config.register_mapper(UsersMapper)
    config.register_mapper(MapperWithoutSchema)
    config.register_mapper(MapperDelegatedSchema)
    config.register_mapper(MapperInheritedDelegatedSchema)
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
    let(:user_repo) { UserRepo.new(container) }
    let(:users) { user_repo.users }
    let(:parsed_collection) { JSON.parse(Surrealist.surrealize_collection(collection)) }

    before(:all) do
      user_repo = UserRepo.new(container)
      [
        { name: 'Jane Struct', email: 'jane@struct.rom' },
        { name: 'Dane As', email: 'dane@as.rom' },
        { name: 'Jack Mapper', email: 'jack@mapper.rom' },
      ].each { |user| user_repo.create(user) }
    end

    context 'with schema defined in ROM::Struct::Model' do
      context 'instance' do
        let(:instance) { users.to_a.first }
        let(:result) { '{"name":"Jane Struct"}' }

        it { expect(instance.surrealize).to eq(result) }
        it_behaves_like 'error is not raised for valid params: instance'
        it_behaves_like 'error is raised for invalid params: instance'

        context '#where().first' do
          let(:instance) { users.where(id: 1).first }
          let(:result) { '{"name":"Jane Struct"}' }

          it { expect(instance.surrealize).to eq(result) }
          it_behaves_like 'error is not raised for valid params: instance'
          it_behaves_like 'error is raised for invalid params: instance'
        end
      end

      context 'collection' do
        let(:collection) { users.to_a }
        let(:result) do
          [{ 'name' => 'Jane Struct' },
           { 'name' => 'Dane As' },
           { 'name' => 'Jack Mapper' }]
        end

        it { expect(parsed_collection).to eq(result) }
        it_behaves_like 'error is not raised for valid params: collection'
        it_behaves_like 'error is raised for invalid params: collection'

        context '#where().to_a' do
          let(:collection) { users.where { id < 4 }.to_a }

          it { expect(parsed_collection).to eq(result) }
          it_behaves_like 'error is not raised for valid params: collection'
          it_behaves_like 'error is raised for invalid params: collection'
        end
      end
    end

    context 'using ROM::Struct::Model#as(Representative)' do
      context 'instance' do
        let(:instance) { users.map_to(RomUser).to_a[1] }
        let(:result) { '{"email":"dane@as.rom"}' }

        it { expect(instance.surrealize).to eq(result) }
        it_behaves_like 'error is not raised for valid params: instance'
        it_behaves_like 'error is raised for invalid params: instance'

        context '#where().first' do
          let(:instance) { users.map_to(RomUser).where(id: 2).first }

          it { expect(instance.surrealize).to eq(result) }
          it_behaves_like 'error is not raised for valid params: instance'
          it_behaves_like 'error is raised for invalid params: instance'
        end
      end

      context 'collection' do
        let(:collection) { users.map_to(RomUser).to_a }
        let(:result) do
          [{ 'email' => 'jane@struct.rom' },
           { 'email' => 'dane@as.rom' },
           { 'email' => 'jack@mapper.rom' }]
        end

        it { expect(parsed_collection).to eq(result) }
        it_behaves_like 'error is not raised for valid params: collection'
        it_behaves_like 'error is raised for invalid params: collection'

        context '#where().to_a' do
          let(:collection) { users.map_to(RomUser).where { id < 4 }.to_a }

          it { expect(parsed_collection).to eq(result) }
          it_behaves_like 'error is not raised for valid params: collection'
          it_behaves_like 'error is raised for invalid params: collection'
        end
      end
    end

    context 'using mapper' do
      context 'instance' do
        let(:instance) { users.map_with(:user_obj).to_a[2] }
        let(:result) { '{"id":3,"email":"jack@mapper.rom"}' }

        it { expect(instance.surrealize).to eq(result) }
        it { expect(users.map_with(:user_obj).to_a.size).to eq(3) }
        it_behaves_like 'error is not raised for valid params: instance'
        it_behaves_like 'error is raised for invalid params: instance'

        context '#where().first' do
          let(:instance) { users.map_with(:user_obj).where(id: 3).first }

          it { expect(instance.surrealize).to eq(result) }
          it_behaves_like 'error is not raised for valid params: instance'
          it_behaves_like 'error is raised for invalid params: instance'
        end
      end

      context 'collection' do
        let(:collection) { users.map_with(:user_obj).to_a }
        let(:result) do
          [{ 'id' => 1, 'email' => 'jane@struct.rom' },
           { 'id' => 2, 'email' => 'dane@as.rom' },
           { 'id' => 3, 'email' => 'jack@mapper.rom' }]
        end

        it { expect(parsed_collection).to eq(result) }
        it_behaves_like 'error is not raised for valid params: collection'
        it_behaves_like 'error is raised for invalid params: collection'

        context '#where().to_a' do
          let(:collection) { users.map_with(:user_obj).where { id < 4 }.to_a }

          it { expect(parsed_collection).to eq(result) }
          it_behaves_like 'error is not raised for valid params: collection'
          it_behaves_like 'error is raised for invalid params: collection'
        end
      end
    end

    context 'with no schema provided' do
      let(:instance) { users.map_with(:user_wo_schema).first }
      let(:collection) { users.map_with(:user_wo_schema).to_a }

      describe 'UnknownSchemaError is raised' do
        specify 'for instance' do
          expect { instance.surrealize }
            .to raise_error(Surrealist::UnknownSchemaError,
                            "Can't serialize SchemalessUser - no schema was provided.")
        end

        specify 'for collection' do
          expect { Surrealist.surrealize_collection(collection) }
            .to raise_error(Surrealist::UnknownSchemaError,
                            "Can't serialize SchemalessUser - no schema was provided.")
        end
      end
    end

    context 'with delegated schema' do
      context 'for instance' do
        let(:instance) { users.map_with(:user_de_schema).to_a[2] }
        let(:result) { '{"id":3,"email":"delegated@example.com"}' }

        it { expect(instance.surrealize).to eq(result) }
        it { expect(users.map_with(:user_de_schema).to_a.size).to eq(3) }
        it_behaves_like 'error is not raised for valid params: instance'
        it_behaves_like 'error is raised for invalid params: instance'

        context '#where().first' do
          let(:instance) { users.map_with(:user_de_schema).where(id: 3).first }

          it { expect(instance.surrealize).to eq(result) }
          it_behaves_like 'error is not raised for valid params: instance'
          it_behaves_like 'error is raised for invalid params: instance'
        end
      end

      context 'for collection' do
        let(:collection) { users.map_with(:user_de_schema).to_a }
        let(:result) do
          [{ 'id' => 1, 'email' => 'delegated@example.com' },
           { 'id' => 2, 'email' => 'delegated@example.com' },
           { 'id' => 3, 'email' => 'delegated@example.com' }]
        end

        it { expect(parsed_collection).to eq(result) }
        it_behaves_like 'error is not raised for valid params: collection'
        it_behaves_like 'error is raised for invalid params: collection'

        context '#where().to_a' do
          let(:collection) { users.map_with(:user_de_schema).where { id < 4 }.to_a }

          it { expect(parsed_collection).to eq(result) }
          it_behaves_like 'error is not raised for valid params: collection'
          it_behaves_like 'error is raised for invalid params: collection'
        end
      end
    end

    context 'with inheritance of class that has delegated but we don\'t delegate' do
      let(:instance) { users.map_with(:user_child_de_schema).first }
      let(:collection) { users.map_with(:user_child_de_schema).to_a }

      describe 'UnknownSchemaError is raised' do
        specify 'for instance' do
          expect { instance.surrealize }
            .to raise_error(Surrealist::UnknownSchemaError,
                            "Can't serialize GrandChildUser - no schema was provided.")
        end

        specify 'for collection' do
          expect { Surrealist.surrealize_collection(collection) }
            .to raise_error(Surrealist::UnknownSchemaError,
                            "Can't serialize GrandChildUser - no schema was provided.")
        end
      end
    end
  end
end
