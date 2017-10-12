require 'active_record'

ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database  => ":memory:"
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
end

class TestAR < ActiveRecord::Base
  include Surrealist

  scope :dummy, ->{ where(type: 'InheritAR' )}

  json_schema do { name: String } end
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

  json_schema do { name: String } end
end

class Author < ActiveRecord::Base
  has_and_belongs_to_many :books

  include Surrealist

  json_schema do { name: String } end
end

class Publisher < ActiveRecord::Base
  include Surrealist

  json_schema do { name: String } end
end

class Award < ActiveRecord::Base
  include Surrealist

  json_schema do { name: String } end
end

class Genre < ActiveRecord::Base
  include Surrealist

  json_schema do { name: String } end
end

3.times { Genre.create(name: ('a'..'z').to_a.shuffle[0,8].join) }
3.times { Author.create(name: ('a'..'z').to_a.shuffle[0,8].join) }
3.times { Book.create(name: ('a'..'z').to_a.shuffle[0,8].join, genre_id: Genre.all.sample.id) }
3.times { Publisher.create(name: ('a'..'z').to_a.shuffle[0,8].join, book_id: Book.all.sample.id) }
3.times { Award.create(name: ('a'..'z').to_a.shuffle[0,8].join, book_id: Book.all.sample.id) }
