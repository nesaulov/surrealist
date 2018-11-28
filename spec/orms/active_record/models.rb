require 'active_record'
require_relative '../../../lib/surrealist'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:',
)

ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :test_ars do |table|
    table.column :name, :string
    table.string :type
  end

  create_table(:schema_less_ars) { |table| table.column :name, :string }

  create_table(:ar_scopes) do |table|
    table.column :title, :string
    table.column :money, :int
  end

  create_table :books do |table|
    table.column :title, :string
    table.integer :genre_id
    table.integer :author_id
    table.integer :publisher_id
    table.integer :award_id
  end

  create_table(:authors) { |table| table.column :name, :string }

  create_table(:genres) { |table| table.column :name, :string }

  create_table :publishers do |table|
    table.column :name, :string
    table.integer :book_id
  end

  create_table :awards do |table|
    table.column :title, :string
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
    table.column :prom_name, :string
  end

  create_table :prom_couples do |table|
    table.column :prom_queen, :string
    table.integer :prom_id
  end

  create_table :prom_kings do |table|
    table.column :prom_king_name, :string
    table.integer :prom_couple_id
  end

  create_table :questions do |table|
    table.column :name, :string
  end

  create_table :answers do |table|
    table.column :name, :string
    table.integer :question_id
  end

  create_table :trees do |table|
    table.column :name, :string
    table.column :height, :int
  end
end

def name_string
  ('a'..'z').to_a.sample(8).join
end

#
#
# Basics
#

class SchemaLessAR < ActiveRecord::Base
  include Surrealist
end

3.times { SchemaLessAR.create!(name: 'testing active record without schema') }

#
#
# Inheritance
#

class TestAR < ActiveRecord::Base
  include Surrealist

  json_schema { { name: String } }
end

class InheritAR < TestAR
  delegate_surrealization_to TestAR
end

class InheritAgainAR < InheritAR
  delegate_surrealization_to TestAR
end

TestAR.create!(name: 'testing active record')
InheritAR.create!(name: 'testing active record inherit')
InheritAgainAR.create!(name: 'testing active record inherit again')

#
#
# Scopes
#

class ARScope < ActiveRecord::Base
  include Surrealist

  # Surrealist.surrealize_collection() should work properly with scopes that return collections.
  scope :coll_where, -> { where(id: 3) }
  scope :coll_where_not, -> { where.not(title: 'nope') }
  scope :coll_order, -> { order(id: :asc) }
  scope :coll_take, -> { take(1) }
  scope :coll_limit, -> { limit(34) }
  scope :coll_offset, -> { offset(43) }
  scope :coll_lock, -> { lock(12) }
  scope :coll_readonly, -> { readonly }
  scope :coll_reorder, -> { reorder(id: :desc) }
  scope :coll_distinct, -> { distinct }
  scope :coll_find_each, -> { find_each { |rec| rec.title.length > 2 } }
  scope :coll_select, -> { select(:title, :money) }
  scope :coll_group, -> { group(:title) }
  scope :coll_order, -> { order(title: :desc) }
  scope :coll_except, -> { except(id: 65) }
  scope :coll_extending, -> { extending Surrealist }
  scope :coll_having, -> { having('sum(money) > 43').group(:money) }
  scope :coll_references, -> { references(:book) }

  # Surrealist.surrealize_collection() will fail with scopes that return an instance.
  scope :rec_find, -> { find(2) }
  scope :rec_find_by, -> { find_by(id: 3) }
  scope :rec_find_by!, -> { find_by!(id: 3) }
  scope :rec_take!, -> { take! }
  scope :rec_first, -> { first }
  scope :rec_first!, -> { first! }
  scope :rec_second, -> { second }
  scope :rec_second!, -> { second! }
  scope :rec_third, -> { third }
  scope :rec_third!, -> { third! }
  scope :rec_fourth, -> { fourth }
  scope :rec_fourth!, -> { fourth! }
  scope :rec_fifth, -> { fifth }
  scope :rec_fifth!, -> { fifth! }
  scope :rec_forty_two, -> { forty_two }
  scope :rec_forty_two!, -> { forty_two! }
  scope :rec_last, -> { last }
  scope :rec_last!, -> { last! }
  scope :rec_third_to_last, -> { third_to_last }
  scope :rec_third_to_last!, -> { third_to_last! }
  scope :rec_second_to_last, -> { second_to_last }
  scope :rec_second_to_last!, -> { second_to_last! }

  json_schema { { title: String, money: Integer } }
end

45.times { ARScope.create!(title: name_string, money: rand(5432)) }

#
#
# Associations
#

class BookSerializer < Surrealist::Serializer
  json_schema { { awards: Object } }
end

class Book < ActiveRecord::Base
  has_and_belongs_to_many :authors
  belongs_to :genre
  has_one :publisher
  has_many :awards

  include Surrealist

  json_schema do
    {
      title: String,
      genre: {
        name: String,
      },
      awards: {
        title: String,
        id: Integer,
      },
    }
  end
  surrealize_with BookSerializer, tag: :awards
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

  json_schema { { title: String } }
end

class Genre < ActiveRecord::Base
  include Surrealist

  json_schema { { name: String } }
end

%w[Adventures Comedy Drama].each_with_index do |name, i|
  Genre.create!(name: name, id: i + 1)
end

%w[Twain Jerome Shakespeare].each_with_index do |name, i|
  Author.create!(name: name, id: i + 1)
end

[
  'The Adventures of Tom Sawyer',
  'Three Men in a Boat',
  'Romeo and Juliet',
].each_with_index do |title, i|
  Book.create!(title: title, id: i + 1, genre_id: i + 1, author_ids: [i + 1])
end

[
  'Cengage Learning',
  'Houghton Mifflin Harcourt',
  'McGraw-Hill Education',
].each_with_index { |name, i| Publisher.create!(name: name, book_id: i + 1) }

3.times do
  [
    'Nobel Prize',
    'Franz Kafka Prize',
    'America Award',
  ].each_with_index { |title, i| Award.create!(title: title, book_id: i + 1) }
end

#
#
# Nested records
#

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

  json_schema { { prom_king_name: String, prom: Object } }
end

class PromCouple < ActiveRecord::Base
  belongs_to :prom
  has_one :prom_king

  include Surrealist

  json_schema { { prom_king: PromKing, prom_queen: String } }
end

class Prom < ActiveRecord::Base
  has_one :prom_couple

  include Surrealist

  json_schema { { prom_name: String, prom_couple: PromCouple } }
end

class Question < ActiveRecord::Base
  has_many :answers

  include Surrealist

  json_schema { { name: String, answers: Object } }
end

class Answer < ActiveRecord::Base
  belongs_to :question

  include Surrealist

  json_schema { { name: String, question: Question } }
end

# Using a separate class

TreeSerializer = Class.new(Surrealist::Serializer) do
  json_schema { { name: String, height: Integer, color: String } }

  def color; 'green'; end
end

class Tree < ActiveRecord::Base
  include Surrealist

  surrealize_with TreeSerializer
end

2.times { Executive.create(name: name_string) }
3.times { Manager.create(name: name_string) }
5.times { Employee.create(name: name_string, manager_id: Manager.all.sample.id) }
Assistant.create(name: name_string, executive_id: Executive.first.id)
Assistant.create(name: name_string, executive_id: Executive.second.id)
Prom.create(prom_name: name_string)
PromCouple.create(prom_id: Prom.first.id, prom_queen: name_string)
PromKing.create(prom_king_name: name_string, prom_couple_id: PromCouple.first.id)
5.times { Question.create(name: name_string) }
10.times { Answer.create(name: name_string, question_id: Question.all.sample.id) }

Tree.create!(name: 'Oak', height: 200)
Tree.create!(name: 'Pine', height: 140)
