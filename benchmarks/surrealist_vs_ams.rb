require_relative '../lib/surrealist'
require 'benchmark/ips'
require 'active_record'
require 'active_model'
require 'active_model_serializers'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: ':memory:',
)

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define do
  create_table :users do |table|
    table.column :name, :string
    table.column :email, :string
  end

  create_table :authors do |table|
    table.column :name, :string
    table.column :last_name, :string
    table.column :age, :int
  end

  create_table :books do |table|
    table.column :title, :string
    table.column :year, :string
    table.belongs_to :author, foreign_key: true
  end
end

ActiveModelSerializers.config.adapter = :json

def random_name
  ('a'..'z').to_a.shuffle.join('').first(10).capitalize
end

class User < ActiveRecord::Base
  include Surrealist

  json_schema { { name: String, email: String } }
end

class UserSerializer < ActiveModel::Serializer
  attributes :name, :email
end

class UserSurrealistSerializer < Surrealist::Serializer
  json_schema { { name: String, email: String } }
end

class UserAMSSerializer < ActiveModel::Serializer
  attributes :name, :email
end

### Associations ###

class AuthorSurrealistSerializer < Surrealist::Serializer
  json_schema do
    { name: String, last_name: String, full_name: String, age: Integer, books: Array }
  end

  def books
    object.books.to_a
  end

  def full_name
    "#{object.name} #{object.last_name}"
  end
end

class BookSurrealistSerializer < Surrealist::Serializer
  json_schema { { title: String, year: String } }
end

class BookAMSSerializer < ActiveModel::Serializer
  attributes :title, :year
end

class AuthorAMSSerializer < ActiveModel::Serializer
  attributes :name, :last_name, :full_name, :age
  has_many :books, serializer: BookAMSSerializer
end

class Author < ActiveRecord::Base
  include Surrealist
  surrealize_with AuthorSurrealistSerializer

  has_many :books

  def full_name
    "#{name} #{last_name}"
  end
end

class Book < ActiveRecord::Base
  include Surrealist
  surrealize_with BookSurrealistSerializer

  belongs_to :author, required: true
end

N = 3000
N.times { User.create!(name: random_name, email: "#{random_name}@test.com") }
(N / 2).times { Author.create!(name: random_name, last_name: random_name, age: rand(80)) }
N.times { Book.create!(title: random_name, year: "19#{rand(10..99)}", author_id: rand(1..N / 2)) }

def sort(obj)
  case obj
  when Array then obj.map { |el| sort(el) }.sort_by(&:zip)
  when Hash then obj.transform_values { |v| sort(v) }
  else obj
  end
end

def check_correctness(serializers)
  results = serializers.map(&:call).map { |r| sort(JSON.parse(r)) }
  raise 'Results are not the same' if results.uniq.size > 1
end

def benchmark(names, serializers)
  check_correctness(serializers)

  Benchmark.ips do |x|
    x.config(time: 5, warmup: 2)

    names.zip(serializers).each { |name, proc| x.report(name, &proc) }

    x.compare!
  end
end

def benchmark_instance(ams_arg = '')
  user = User.find(rand(1..N))

  names = ["AMS#{ams_arg}: instance",
           'Surrealist: instance through .surrealize',
           'Surrealist: instance through Surrealist::Serializer']

  serializers = [-> { UserAMSSerializer.new(user).to_json },
                 -> { user.surrealize },
                 -> { UserSurrealistSerializer.new(user).surrealize }]

  benchmark(names, serializers)
end

def benchmark_collection(ams_arg = '')
  users = User.all

  names = ["AMS#{ams_arg}: collection",
           'Surrealist: collection through Surrealist.surrealize_collection()',
           'Surrealist: collection through Surrealist::Serializer']

  serializers = [lambda do
                   ActiveModel::Serializer::CollectionSerializer.new(
                     users, root: nil, serializer: UserAMSSerializer
                   ).to_json
                 end,
                 -> { Surrealist.surrealize_collection(users) },
                 -> { UserSurrealistSerializer.new(users).surrealize }]

  benchmark(names, serializers)
end

def benchmark_associations_instance
  instance = Author.find(rand((1..(N / 2))))

  names = ['AMS (associations): instance',
           'Surrealist (associations): instance through .surrealize',
           'Surrealist (associations): instance through Surrealist::Serializer']

  serializers = [-> { AuthorAMSSerializer.new(instance).to_json },
                 -> { instance.surrealize },
                 -> { AuthorSurrealistSerializer.new(instance).surrealize }]

  benchmark(names, serializers)
end

def benchmark_associations_collection
  collection = Author.all

  names = ['AMS (associations): collection',
           'Surrealist (associations): collection through Surrealist.surrealize_collection()',
           'Surrealist (associations): collection through Surrealist::Serializer']

  serializers = [lambda do
                   ActiveModel::Serializer::CollectionSerializer.new(
                     collection, root: nil, serializer: AuthorAMSSerializer
                   ).to_json
                 end,
                 -> { Surrealist.surrealize_collection(collection) },
                 -> { AuthorSurrealistSerializer.new(collection).surrealize }]

  benchmark(names, serializers)
end

# Default configuration
benchmark_instance
benchmark_collection

# With AMS logger turned off
puts "\n------- Turning off AMS logger -------\n"
ActiveModelSerializers.logger.level = Logger::Severity::UNKNOWN

benchmark_instance('(without logging)')
benchmark_collection('(without logging)')

# Associations
benchmark_associations_instance
benchmark_associations_collection

# ruby 2.5.0p0 (2017-12-25 revision 61468) [x86_64-darwin16]
# -- Instance --
# Comparison:
#   Surrealist: instance through .surrealize:    39599.6 i/s
#   Surrealist: instance through Surrealist::Serializer:    36452.5 i/s - same-ish: difference falls within error
#   AMS: instance:     1938.9 i/s - 20.42x  slower
#
# -- Collection --
# Comparison:
#   Surrealist: collection through Surrealist.surrealize_collection():       15.0 i/s
#   Surrealist: collection through Surrealist::Serializer:       12.8 i/s - 1.17x  slower
#   AMS: collection:        6.1 i/s - 2.44x  slower
#
# --- Without AMS logging (which is turned on by default) ---
#
# -- Instance --
# Comparison:
#   Surrealist: instance through .surrealize:    40401.4 i/s
#   Surrealist: instance through Surrealist::Serializer:    29488.3 i/s - 1.37x  slower
#   AMS(without logging): instance:     4571.7 i/s - 8.84x  slower
#
# -- Collection --
# Comparison:
#   Surrealist: collection through Surrealist.surrealize_collection():       15.2 i/s
#   Surrealist: collection through Surrealist::Serializer:       12.0 i/s - 1.27x  slower
#   AMS(without logging): collection:        6.1 i/s - 2.50x  slower
#
# --- Associations ---
#
# -- Instance --
# Comparison:
#   Surrealist (associations): instance through Surrealist::Serializer:     4016.3 i/s
#   Surrealist (associations): instance through .surrealize:     4004.6 i/s - same-ish: difference falls within error
#   AMS (associations): instance:     1303.0 i/s - 3.08x  slower
#
# -- Collection --
# Comparison:
#   Surrealist (associations): collection through Surrealist.surrealize_collection():        2.4 i/s
#   Surrealist (associations): collection through Surrealist::Serializer:        2.4 i/s - 1.03x  slower
#   AMS (associations): collection:        1.5 i/s - 1.60x  slower
