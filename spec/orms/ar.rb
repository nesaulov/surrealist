require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:',
)

ActiveRecord::Schema.define do
  create_table :test_ars do |table|
    table.column :name, :string
    table.string :type
  end

  create_table :books do |table|
    table.column :name, :string
    table.integer :genre_id
  end

  create_table :authors do |table|
    table.column :name, :string
  end

  create_table :genres do |table|
    table.column :name, :string
  end

  create_table :publishers do |table|
    table.column :name, :string
    table.integer :book_id
  end

  create_table :awards do |table|
    table.column :name, :string
    table.integer :book_id
  end

  create_table :authors_books do |table|
    table.integer :author_id
    table.integer :book_id
  end

  create_table :employees do |table|
    table.column :name, :string
    table.integer :manager_id
  end

  create_table :managers do |table|
    table.column :name, :string
  end

  create_table :executives do |table|
    table.column :name, :string
    table.integer :ceo_id
  end

  create_table :assistants do |table|
    table.column :name, :string
    table.integer :executive_id
  end

  create_table :proms do |table|
    table.column :name, :string
  end

  create_table :prom_couples do |table|
    table.column :name, :string
    table.column :prom_queen, :string
    table.integer :prom_id
  end

  create_table :prom_kings do |table|
    table.column :name, :string
    table.integer :prom_couple_id
  end
end

class TestAR < ActiveRecord::Base
  include Surrealist

  scope :sub_collection, -> { where(type: 'InheritAR') }
  scope :sub_record, -> { find_by(type: 'InheritAR') }

  json_schema { { name: String } }
end
TestAR.create(name: 'testing active record')

class InheritAR < TestAR
  delegate_surrealization_to TestAR
end
InheritAR.create(name: 'testing active record inherit')

class InheritAgainAR < InheritAR
  delegate_surrealization_to TestAR
end
InheritAgainAR.create(name: 'testing active record inherit again')

class InheritWithoutSchemaAR < TestAR; end

class Book < ActiveRecord::Base
  has_and_belongs_to_many :authors
  belongs_to :genre
  has_one :publisher
  has_many :awards

  include Surrealist

  json_schema { { name: String } }
end

class Author < ActiveRecord::Base
  has_and_belongs_to_many :books

  include Surrealist

  json_schema { { name: String } }
end

class Publisher < ActiveRecord::Base
  include Surrealist

  json_schema { { name: String } }
end

class Award < ActiveRecord::Base
  include Surrealist

  json_schema { { name: String } }
end

class Genre < ActiveRecord::Base
  include Surrealist

  json_schema { { name: String } }
end

class Executive < ActiveRecord::Base
  has_one :assistant

  include Surrealist

  json_schema { { name: String, assistant: Object } }
end

class Assistant < ActiveRecord::Base
  belongs_to :executive

  include Surrealist

  json_schema { { name: String, executive: Executive } }
end

class Manager < ActiveRecord::Base
  has_many :employees
  belongs_to :executive

  include Surrealist

  json_schema { { name: String } }
end

class Employee < ActiveRecord::Base
  belongs_to :manager

  include Surrealist

  json_schema { { name: String, manager: Manager } }
end

class PromKing < ActiveRecord::Base
  belongs_to :prom_couple
  has_one :prom, through: :prom_couple

  include Surrealist

  json_schema { { name: String, prom: Object } }
end

class PromCouple < ActiveRecord::Base
  belongs_to :prom
  has_one :prom_king

  include Surrealist

  json_schema { { name: String, prom_king: PromKing, prom_queen: String } }
end

class Prom < ActiveRecord::Base
  has_one :prom_couple

  include Surrealist

  json_schema { { name: String, prom_couple: PromCouple } }
end

def name_string
  ('a'..'z').to_a.sample(8).join
end

3.times { Genre.create(name: name_string) }
3.times { Author.create(name: name_string) }
3.times { Book.create(name: name_string, genre_id: Genre.all.sample.id) }
3.times { Publisher.create(name: name_string, book_id: Book.all.sample.id) }
3.times { Award.create(name: name_string, book_id: Book.all.sample.id) }
2.times { Executive.create(name: name_string, ceo_id: CEO.all.sample.id) }
3.times { Manager.create(name: name_string) }
5.times { Employee.create(name: name_string, manager_id: Manager.all.sample.id) }
Assistant.create(name: name_string, executive_id: Executive.first.id)
Assistant.create(name: name_string, executive_id: Executive.second.id)
Prom.create(name: name_string)
PromCouple.create(name: name_string, prom_id: Prom.first.id, prom_queen: name_string)
PromKing.create(name: name_string, prom_couple_id: PromCouple.first.id)
