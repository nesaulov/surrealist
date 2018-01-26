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
ActiveModelSerializers.logger.level = Logger::Severity::UNKNOWN

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

Benchmark.ips do |x|
  # Instance serialization
  user = User.find(rand(1..N))
  instance_ams_serializer = ActiveModelSerializers::SerializableResource.new(user)
  instance_surrealist_serializer = UserSurrealistSerializer.new(user)

  x.config(time: 5, warmup: 2)

  x.report('AMS: instance') do
    instance_ams_serializer.to_json
  end

  x.report('Surrealist: instance through .surrealize') do
    user.surrealize
  end

  x.report('Surrealist: instance through Surrealist::Serializer') do
    instance_surrealist_serializer.surrealize
  end

  x.compare!
end

Benchmark.ips do |x|
  # Collection serialization
  users = User.all
  coll_ams_serializer = ActiveModelSerializers::SerializableResource.new(users)
  coll_surrealist_serializer = UserSurrealistSerializer.new(users)

  x.config(time: 5, warmup: 2)

  x.report('AMS: collection') do
    coll_ams_serializer.to_json
  end

  x.report('Surrealist: collection through Surrealist.surrealize_collection()') do
    Surrealist.surrealize_collection(users)
  end

  x.report('Surrealist: collection through Surrealist::Serializer') do
    coll_surrealist_serializer.surrealize
  end

  x.compare!
end
