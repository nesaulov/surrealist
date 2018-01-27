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
end

def random_name
  ('a'..'z').to_a.shuffle.join('').first(10)
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

N = 3000

N.times { User.create!(name: random_name, email: "#{random_name}@test.com") }

user = User.find(rand(1..N))
users = User.all

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report('AMS: instance') do
    ActiveModelSerializers::SerializableResource.new(user).to_json
  end

  x.report('Surrealist: instance through .surrealize') do
    user.surrealize
  end

  x.report('Surrealist: instance through Surrealist::Serializer') do
    UserSurrealistSerializer.new(user).surrealize
  end

  x.compare!
end

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report('AMS: collection') do
    ActiveModelSerializers::SerializableResource.new(users).to_json
  end

  x.report('Surrealist: collection through Surrealist.surrealize_collection()') do
    Surrealist.surrealize_collection(users)
  end

  x.report('Surrealist: collection through Surrealist::Serializer') do
    UserSurrealistSerializer.new(users).surrealize
  end

  x.compare!
end


# With AMS logger turned off
#
puts "\n------- Turning off AMS logger -------\n"
ActiveModelSerializers.logger.level = Logger::Severity::UNKNOWN

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report('AMS (without logging): instance') do
    ActiveModelSerializers::SerializableResource.new(user).to_json
  end

  x.report('Surrealist: instance through .surrealize') do
    user.surrealize
  end

  x.report('Surrealist: instance through Surrealist::Serializer') do
    UserSurrealistSerializer.new(user).surrealize
  end

  x.compare!
end

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report('AMS (without logging): collection') do
    ActiveModelSerializers::SerializableResource.new(users).to_json
  end

  x.report('Surrealist: collection through Surrealist.surrealize_collection()') do
    Surrealist.surrealize_collection(users)
  end

  x.report('Surrealist: collection through Surrealist::Serializer') do
    UserSurrealistSerializer.new(users).surrealize
  end

  x.compare!
end


# -- Instance --
# Comparison:
# Surrealist: instance through .surrealize:    18486.8 i/s
# Surrealist: instance through Surrealist::Serializer:    15289.3 i/s - same-ish: difference falls within error
# AMS: instance:     2402.3 i/s - 7.70x  slower

# -- Collection --
# Comparison:
# Surrealist: collection through Surrealist.surrealize_collection():        7.2 i/s
# Surrealist: collection through Surrealist::Serializer:        6.7 i/s - same-ish: difference falls within error
# AMS: collection:        5.9 i/s - same-ish: difference falls within error

# --- Without AMS logging ---
#
# -- Instance --
# Comparison:
# Surrealist: instance through .surrealize:    19634.9 i/s
# Surrealist: instance through Surrealist::Serializer:    18273.5 i/s - same-ish: difference falls within error
# AMS (without logging): instance:     6570.4 i/s - 2.99x  slower

# -- Collection --
# Comparison:
# Surrealist: collection through Surrealist.surrealize_collection():        7.2 i/s
# Surrealist: collection through Surrealist::Serializer:        7.0 i/s - same-ish: difference falls within error
# AMS (without logging): collection:        5.6 i/s - same-ish: difference falls within error
