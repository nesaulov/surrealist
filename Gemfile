# frozen_string_literal: true

source 'https://rubygems.org'
gemspec

gem 'coveralls', require: false
gem 'yard', require: false unless ENV['TRAVIS']

group :development, :test do
  gem 'sqlite3'
  gem 'activerecord'
  gem 'sequel'
  gem 'data_mapper'
  gem 'dm-sqlite-adapter'
  gem 'pry'
  gem 'rom'
  gem 'rom-sql'
end
