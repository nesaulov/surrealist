require 'active_record'
require 'pry'
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
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
    table.integer :author_id
    table.integer :publisher_id
    table.integer :award_id
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
    table.column :title, :string
    table.integer :book_id
  end

  create_table :authors_books do |table|
    table.integer :author_id
    table.integer :book_id
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

  json_schema do
    {
      name:  String,
      genre: {
        name: String,
      },
      awards: {
        title: String,
      }
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
