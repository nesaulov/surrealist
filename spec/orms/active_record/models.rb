require 'active_record'
require 'pry'
require_relative '../../../lib/surrealist'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: ':memory:',
)

ActiveRecord::Schema.define do
  create_table :test_ars do |table|
    table.column :name, :string
    table.string :type
  end

  create_table(:schema_less_ars) { |table| table.column :name, :string }

  create_table(:ar_scopes) { |table| table.column :title, :string }

  create_table :books do |table|
    table.column :name, :string
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
end

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
  scope :coll_reorder, -> { reorder(id: :asc) }
  scope :coll_distinct, -> { distinct }
  scope :coll_find_each, -> { find_each { |rec| rec.title.length > 2 } }

  # delegate :find_each, :find_in_batches, :in_batches, to: :all
  # delegate :select, :group, :order, :except, :reorder, :limit, :offset, :joins, :left_joins,
  # :left_outer_joins, :or,
  #          :where, :rewhere, :preload, :eager_load, :includes, :from, :lock, :readonly, :extending,
  #          :having, :create_with, :distinct, :references, :none, :unscope, :merge, to: :all
  # delegate :count, :average, :minimum, :maximum, :sum, :calculate, to: :all
  # delegate :pluck, :ids, to: :all
  # CLAUSE_METHODS = [:where, :having, :from]
  # INVALID_METHODS_FOR_DELETE_ALL = [:limit, :distinct, :offset, :group, :having]

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
  scope :rec_third_to_last, -> { third_to_last }
  scope :rec_third_to_last!, -> { third_to_last! }
  scope :rec_second_to_last, -> { second_to_last }
  scope :rec_second_to_last!, -> { second_to_last! }
  scope :rec_last, -> { last }
  scope :rec_last!, -> { last! }

  json_schema { { title: String } }
end

45.times { ARScope.create!(title: ('a'..'z').to_a.sample(8).join) }

# Associations

class Book < ActiveRecord::Base
  has_and_belongs_to_many :authors
  belongs_to :genre
  has_one :publisher
  has_many :awards

  include Surrealist

  json_schema do
    {
      name:  String,
      genre: {
        name: String,
      },
      awards: {
        title: String,
      },
    }
  end
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
# binding.pry
[
  'The Adventures of Tom Sawyer',
  'Three Men in a Boat',
  'Romeo and Juliet',
].each_with_index do |name, i|
  Book.create!(name: name, id: i + 1, genre_id: i + 1, author_id: i + 1)
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
  ].shuffle.each_with_index { |title, i| Award.create!(title: title, book_id: i + 1) }
end
# 3.times { Genre.create(name: ('a'..'z').to_a.sample(8).join) }
# 3.times { Author.create(name: ('a'..'z').to_a.sample(8).join) }
# 3.times { Book.create(name: ('a'..'z').to_a.sample(8).join, genre_id: Genre.all.sample.id) }
# 3.times { Publisher.create(name: ('a'..'z').to_a.sample(8).join, book_id: Book.all.sample.id) }
# 3.times { Award.create(name: ('a'..'z').to_a.sample(8).join, book_id: Book.all.sample.id) }
