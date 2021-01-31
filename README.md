# Surrealist
[![Build Status](https://travis-ci.org/nesaulov/surrealist.svg?branch=master)](https://travis-ci.org/nesaulov/surrealist)
[![Coverage Status](https://coveralls.io/repos/github/nesaulov/surrealist/badge.svg?branch=master)](https://coveralls.io/github/nesaulov/surrealist?branch=master)
[![Inline docs](http://inch-ci.org/github/nesaulov/surrealist.svg?branch=master)](http://inch-ci.org/github/nesaulov/surrealist)
[![Gem Version](https://badge.fury.io/rb/surrealist.svg)](https://rubygems.org/gems/surrealist)
[![Open Source Helpers](https://www.codetriage.com/nesaulov/surrealist/badges/users.svg)](https://www.codetriage.com/nesaulov/surrealist)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)

![Surrealist](surrealist-icon.png)

Surrealist is a schema-driven object serialization ruby library. It also provides a trivial type checking in the runtime before serialization.
[Yard documentation](http://www.rubydoc.info/github/nesaulov/surrealist/master)


## Motivation
A typical use case for this gem could be, for example, serializing a (decorated) object outside
of the view context. The schema is described through a hash, so you can build the structure
of serialized object independently of its methods and attributes, while also having possibility
to serialize nested objects and structures. [Introductory blogpost.](https://medium.com/@billikota/introducing-surrealist-a-gem-to-serialize-ruby-objects-according-to-a-defined-schema-6ca7e550628d)

* [Installation](#installation)
* [Usage](#usage)
  * [Simple example](#simple-example)
  * [Nested structures](#nested-structures)
  * [Nested objects](#nested-objects)
  * [Collection Surrealization](#collection-surrealization)
  * [Defining custom serializers](#defining-custom-serializers)
  * [Multiple serializers](#multiple-serializers)
  * [Build schema](#build-schema)
  * [Defined schema](#defined-schema)
  * [Working with ORMs](#working-with-orms)
    * [ActiveRecord](#activerecord)
    * [ROM](#rom)
    * [Sequel](#sequel)
  * [Usage with Dry::Types](#usage-with-drytypes)
  * [Delegating Surrealization](#delegating-surrealization)
  * [Optional arguments](#optional-arguments)
    * [Camelization](#camelization)
    * [Include root](#include-root)
    * [Root](#root)
    * [Include namespaces](#include-namespaces)
  * [Configuration](#configuration)
  * [Hash serialization](#hash-serialization)
  * [Bool and Any](#bool-and-any)
  * [Type errors](#type-errors)
  * [Undefined methods in schema](#undefined-methods-in-schema)
  * [Other notes](#other-notes)
* [Roadmap](#roadmap)
* [Contributing](#contributing)
* [Credits](#credits)
* [Authors](#authors)
* [License](#license)


## Installation
Add this line to your application's Gemfile:

``` ruby
gem 'surrealist'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install surrealist


## Usage
Schema should be defined with a block that contains a hash. Every key of the schema should be
either a name of a method of the surrealizable object (or it's ancestors/mixins),
or - in case you want to build json structure independently from object's structure - a symbol.
Every value of the hash should be a constant that represents a Ruby class,
that will be used for type-checks.

### Simple example
* Include Surrealist in your class.
* Define a schema with methods that need to be serialized.

``` ruby
class Person
  include Surrealist

  json_schema do
    { name: String, age: Integer }
  end

  def name
    'John Doe'
  end

  def age
    42
  end
end
```

* Surrealize it.

``` ruby
Person.new.surrealize
# => '{ "name": "John Doe", "age": 42 }'
```

### Nested structures

``` ruby
class Person
  include Surrealist

  json_schema do
    {
      foo: String,
      name: String,
      nested: {
        at: {
          any: Integer,
          level: Bool,
        },
      },
    }
  end
  # ... method definitions
end

Person.find_by(email: 'example@email.com').surrealize
# => '{ "foo": "Some string", "name": "John Doe", "nested": { "at": { "any": 42, "level": true } } }'
```

### Nested objects
If you need to serialize nested objects and their attributes, you should
define a method that calls nested object:

``` ruby
class User
  include Surrealist

  json_schema do
    {
      name: String,
      credit_card: {
        number: Integer,
        cvv: Integer,
      },
    }
  end

  def name
    'John Doe'
  end

  def credit_card
    # Assuming that instance of a CreditCard has methods #number and #cvv defined
    CreditCard.find_by(holder: name)
  end
end

User.new.surrealize
# => '{ "name": "John Doe", "credit_card": { "number": 1234, "cvv": 322 } }'

```

### Collection Surrealization
Since 0.2.0 Surrealist has API for collection serialization. Example for ActiveRecord:
``` ruby
class User < ActiveRecord::Base
  include Surrealist

  json_schema do
    { name: String, age: Integer }
  end
end

users = User.all
# => [#<User:0x007fa1485de878 id: 1, name: "Nikita", age: 23>, #<User:0x007fa1485de5f8 id: 2, name: "Alessandro", age: 24>]

Surrealist.surrealize_collection(users)
# => '[{ "name": "Nikita", "age": 23 }, { "name": "Alessandro", "age": 24 }]'
```
You can find motivation behind introducing new API versus monkey-patching [here](https://alessandrominali.github.io/monkey_patching_real_example).
`#surrealize_collection` works for all data structures that behave like `Enumerable`. All ActiveRecord
features (like associations, inheritance etc) are supported and covered. Further reading: [working with ORMs](#working-with-orms).
All optional arguments (`camelize`, `include_root` etc) are also supported.

An additional and unique argument for `#surrealize_collection` is `raw` which is evaluated as a Boolean.
If this option is 'truthy' then the results will be an array of surrealized hashes (i.e. NOT a JSON string).
```
Surrealist.surrealize_collection(users, raw: true)
# => [{ "name": "Nikita", "age": 23 }, { "name": "Alessandro", "age": 24 }]
```

### Defining custom serializers
If you need to keep serialization logic separately from the model, you can define a class that
will inherit from `Surrealist::Serializer`. To point to that class from the model use a class method
`.surrealize_with`. Example usage:
``` ruby
class CatSerializer < Surrealist::Serializer
  json_schema { { age: Integer, age_group: String } }

  def age_group
    age <= 5 ? 'kitten' : 'cat'
  end
end

class Cat
  include Surrealist
  attr_reader :age

  surrealize_with CatSerializer

  def initialize(age)
    @age = age
  end
end

Cat.new(12).surrealize # Implicit usage through .surrealize_with
# => '{ "age": 12, "age_group": "cat" }'

CatSerializer.new(Cat.new(3)).surrealize # explicit usage of CatSerializer
# => '{ "age": 3, "age_group": "kitten" }'
```
The constructor of `Surrealist::Serializer` takes two arguments: serializable model (or collection) and
a context hash. So if there is an object that is not coupled to serializable model
but it is still necessary for constructing JSON, you can pass it to constructor as a hash. It will
be available in the serializer in the `context` hash.
``` ruby
class IncomeSerializer < Surrealist::Serializer
  json_schema { { amount: Integer } }

  def amount
    current_user.guest? ? 100000000 : object.amount
  end

  def current_user
    context[:current_user]
  end
end

class Income
  include Surrealist
  surrealize_with IncomeSerializer

  attr_reader :amount

  def initialize(amount)
    @amount = amount
  end
end

income = Income.new(200)
IncomeSerializer.new(income, current_user: GuestUser.new).surrealize
# => '{ "amount": 100000000 }'

IncomeSerializer.new(income, current_user: User.find(3)).surrealize
# => '{ "amount": 200 }'
```
If you happen to pass a context to a serializer, there is a handy DSL to reduce the number of methods
you have to define yourself. DSL looks as follows
``` ruby
class IncomeSerializer < Surrealist::Serializer
  serializer_context :current_user
  json_schema { { amount: Integer } }

  def amount
    current_user.guest? ? 100000000 : object.amount
  end
end
```
`.serializer_context` takes an array of symbols and dynamically defines instance methods
that read values from the context hash. So `.serializer_context :current_user` will become
``` ruby
def current_user
  context[:current_user]
end
```
There is also an alias in the plural form: `.serializer_contexts`.
### Multiple serializers

You can define several custom serializers for one object and use it in different cases. Just mark it with a tag:

``` ruby
class PostSerializer < Surrealist::Serializer
  json_schema { { id: Integer, title: String, author: { name: String } } }
end

class PreviewSerializer < Surrealist::Serializer
  json_schema { { id: Integer, title: String } }
end

class Post
  include Surrealist

  surrealize_with PostSerializer
  surrealize_with PreviewSerializer, tag: :preview

  attr_reader :id, :title, :author
end
```

And then specify serializer's tag with `for` argument:
``` ruby
author = Struct.new(:name).new("John")
post = Post.new(1, "Ruby is awesome", author)
post.surrealize # => '{ "id": 1, "title": "Ruby is awesome", author: { name: "John" } }'

post.surrealize(for: :preview) # => '{ "id": 1, "title": "Ruby is awesome" }'
```
Or specify serializer explicitly with `serializer` argument:

``` ruby
post.surrealize(serializer: PreviewSerializer) # => '{ "id": 1, "title": "Ruby is awesome" }'
```

### Build schema
If you don't need to dump the hash to json, you can use `#build_schema`
method on the instance. It calculates values and checks types, but returns
a hash instead of a JSON string. From the previous example:

``` ruby
Car.new.build_schema
# => { age: 7, brand: "Toyota", doors: nil, horsepower: 140, fuel_system: "Direct injection", previous_owner: "John Doe" }
```

### Defined schema
Use the `.defined_schema` method to get the schema that has been defined with `json_schema`:

``` ruby
User.defined_schema
# => { name: String, age: Integer }
```

### Working with ORMs

There are two kinds of return values of ORM methods: some return collections of objects, while others return instances.
For the first ones one should use `instance#surrealize`, whereas for the second ones `Surrealist.surrealize_collection(collection)`
Please keep in mind that if your serialization logic is [kept in a separate class](#defining-custom-serializers) which is inherited from
`Surrealist::Serializer`, than usage boils down to `YourSerializer.new(instance || collection).surrealize`.

#### ActiveRecord
All associations work as expected: `.has_many`, `.has_and_belongs_to_many` return collections,
`.has_one`, `.belongs_to` return instances.

Methods that return instances:
``` ruby
.find
.find_by
.find_by!
.take!
.first
.first!
.second
.second!
.third
.third!
.fourth
.fourth!
.fifth
.fifth!
.forty_two
.forty_two!
.last
.last!
.third_to_last
.third_to_last!
.second_to_last
.second_to_last!
```
Methods that return collections:
``` ruby
.all
.where
.where_not
.order
.take
.limit
.offset
.lock
.readonly
.reorder
.distinct
.find_each
.select
.group
.order
.except
.extending
.having
.references
.includes
.joins
```

#### ROM

For detailed usage example (covering ROM 3.x and ROM 4.x) please see `spec/orms/rom/`.
Under the hood ROM uses Sequel, and Sequel returns instances only on `.first`, `.last`, `.[]` and `.with_pk!`.
Collections are returned for all other methods.
``` ruby
container = ROM.container(:sql, ['sqlite::memory']) do |conf|
  conf.default.create_table(:users) do
    primary_key :id
    column :name, String, null: false
    column :email, String, null: false
  end
  # ...
end

users = UserRepo.new(container).users
# => #<ROM::Relation[Users] name=ROM::Relation::Name(users) dataset=#<Sequel::SQLite::Dataset: "SELECT `users`.`id`, `users`.`name`, `users`.`email` FROM `users` ORDER BY `users`.`id`">>
```
Basically, there are several ways to fetch/represent data in ROM:
``` ruby
# With json_schema defined in ROM::Struct::User
class ROM::Struct::User < ROM::Struct
  include Surrealist

  json_schema { { name: String } }
end

users.to_a.first # => #<ROM::Struct::User id=1 name="Jane Struct" email="jane@struct.rom">
users.to_a.first.surrealize # => "{\"name\":\"Jane Struct\"}"

users.where(id: 1).first # => #<ROM::Struct::User id=1 name="Jane Struct" email="jane@struct.rom">
users.where(id: 1).first.surrealize # => "{\"name\":\"Jane Struct\"}"

Surrealist.surrealize_collection(users.to_a) # => "[{\"name\":\"Jane Struct\"},{\"name\":\"Dane As\"},{\"name\":\"Jack Mapper\"}]"

# using ROM::Struct::Model#as(Representative) with json_schema defined in representative
class RomUser < Dry::Struct
  include Surrealist

  attribute :name, String
  attribute :email, String

  json_schema { { email: String } }
end

# ROM 3.x
rom_users = users.as(RomUser).to_a

# ROM 4.x
rom_users = users.map_to(RomUser).to_a

rom_users[1].surrealize # => "{\"email\":\"dane@as.rom\"}"
Surrealist.surrealize_collection(rom_users) # => "[{\"email\":\"jane@struct.rom\"},{\"email\":\"dane@as.rom\"},{\"email\":\"jack@mapper.rom\"}]"

# using Mappers
class UserModel
  include Surrealist

  json_schema { { id: Integer, email: String } }

  attr_reader :id, :name, :email

  def initialize(attributes)
    @id, @name, @email = attributes.values_at(:id, :name, :email)
  end
end

class UsersMapper < ROM::Mapper
  register_as :user_obj
  relation :users
  model UserModel
end

# ROM 3.x
mapped = users.as(:user_obj)
# ROM 4.x
mapped = users.map_with(:user_obj)

mapped.to_a[2] # => #<UserModel:0x00007f8ec19fb3c8 @email="jack@mapper.rom", @id=3, @name="Jack Mapper">
mapped.where(id: 3).first # => #<UserModel:0x00007f8ec19fb3c8 @email="jack@mapper.rom", @id=3, @name="Jack Mapper">
mapped.to_a[2].surrealize # => "{\"id\":3,\"email\":\"jack@mapper.rom\"}"
Surrealist.surrealize_collection(mapped.to_a) # => "[{\"email\":\"jane@struct.rom\"},{\"email\":\"dane@as.rom\"},{\"email\":\"jack@mapper.rom\"}]"
Surrealist.surrealize_collection(mapped.where { id < 4 }.to_a) # => "[{\"email\":\"jane@struct.rom\"},{\"email\":\"dane@as.rom\"},{\"email\":\"jack@mapper.rom\"}]"
```

#### Sequel
Basically, Sequel returns instances only on `.first`, `.last`, `.[]` and `.with_pk!`. Collections are returned for all other methods.
Most of them are covered in `spec/orms/sequel` specs, please refer to them for code examples.
Associations serialization works the same way as it does with ActiveRecord.

### Usage with Dry::Types
You can use `Dry::Types` for type checking. Note that Surrealist does not ship
with dry-types by default, so you should do the [installation and configuration](http://dry-rb.org/gems/dry-types/)
by yourself. All built-in features of dry-types work, so if you use, say, `Types::Coercible::String`,
your data will be coerced if it is able to, otherwise you will get a TypeError.
Assuming that you have defined module called `Types`:

``` ruby
require 'dry-types'

class Car
  include Surrealist

  json_schema do
    {
      age:            Types::Coercible::Integer,
      brand:          Types::Coercible::String,
      doors:          Types::Integer.optional,
      horsepower:     Types::Strict::Integer.constrained(gteq: 20),
      fuel_system:    Types::Any,
      previous_owner: Types::String,
    }
  end

  def age;
    '7'
  end

  def previous_owner;
    'John Doe'
  end

  def horsepower;
    140
  end

  def brand;
    'Toyota'
  end

  def doors; end

  def fuel_system;
    'Direct injection'
  end
end

Car.new.surrealize
# => '{ "age": 7, "brand": "Toyota", "doors": null, "horsepower": 140, "fuel_system": "Direct injection", "previous_owner": "John Doe" }'
```

### Delegating surrealization
You can share the `json_schema` between classes:
``` ruby
class Host
  include Surrealist

  json_schema do
    { name: String }
  end

  def name
    'Host'
  end
end

class Guest
  delegate_surrealization_to Host

  def name
    'Guest'
  end
end

Host.new.surrealize
# => '{ "name": "Host" }'
Guest.new.surrealize
# => '{ "name": "Guest" }'
```
Schema delegation works without inheritance as well, so if you wish you can
delegate surrealization not only to parent classes, but to any class. Please note that
in this case you have to `include Surrealist` in class that delegates schema as well.
``` ruby
class Potato
  include Surrealist
  delegate_surrealization_to Host

  def name
    'Potato'
  end
end

Potato.new.surrealize
# => '{ "name": "Potato" }'
```

### Optional arguments

#### Camelization
If you need to have keys in camelBack, you can pass optional `camelize` argument
to `#surrealize or #build_schema`. From the previous example:

``` ruby
Car.new.surrealize(camelize: true)
# => '{ "age": 7, "brand": "Toyota", "doors": null, "horsepower": 140, "fuelSystem": "Direct injection", "previousOwner": "John Doe" }'
```

#### Include root
If you want to wrap the resulting JSON into a root key, you can pass optional `include_root` argument
to `#surrealize` or `#build_schema`. The root key in this case will be taken from the class name of the
surrealizable object.
``` ruby
class Cat
  include Surrealist

  json_schema do
    { weight: String }
  end

  def weight
    '3 kilos'
  end
end

Cat.new.surrealize(include_root: true)
# => '{ "cat": { "weight": "3 kilos" } }'
```
With nested classes the last namespace will be taken as root key:
``` ruby
class Animal
  class Dog
    include Surrealist

    json_schema do
      { breed: String }
    end

    def breed
      'Collie'
    end
  end
end

Animal::Dog.new.surrealize(include_root: true)
# => '{ "dog": { "breed": "Collie" } }'
```

#### Root
If you want to wrap the resulting JSON into a specified root key, you can pass optional `root` argument
to `#surrealize` or `#build_schema`. The `root` argument will be stripped of whitespaces.
``` ruby
class Cat
  include Surrealist

  json_schema do
    { weight: String }
  end

  def weight
    '3 kilos'
  end
end

Cat.new.surrealize(root: :kitten)
# => '{ "kitten": { "weight": "3 kilos" } }'
Cat.new.surrealize(root: ' kitten ')
# => '{ "kitten": { "weight": "3 kilos" } }'
```
This overrides the `include_root` and `include_namespaces` arguments.
``` ruby
Animal::Cat.new.surrealize(include_root: true, root: :kitten)
# => '{ "kitten": { "weight": "3 kilos" } }'
Animal::Cat.new.surrealize(include_namespaces: true, root: 'kitten')
# => '{ "kitten": { "weight": "3 kilos" } }'
```

#### Include namespaces
You can build wrap schema into a nested hash from namespaces of the object's class.
``` ruby
class BusinessSystem::Cashout::ReportSystem::Withdraws
  include Surrealist

  json_schema do
    { withdraws_amount: Integer }
  end

  def withdraws_amount
    34
  end
end

withdraws = BusinessSystem::Cashout::ReportSystem::Withdraws.new

withdraws.surrealize(include_namespaces: true)
# => '{ "business_system": { "cashout": { "report_system": { "withdraws": { "withdraws_amount": 34 } } } } }'
```
By default all namespaces will be taken. If you want you can explicitly specify the level of nesting:
``` ruby
withdraws.surrealize(include_namespaces: true, namespaces_nesting_level: 2)
# => '{ "report_system": { "withdraws": { "withdraws_amount": 34 } } }'
```

### Configuration

There are two ways of setting default arguments for serialization,
by passing a block to `Surrealist.configure`:
``` ruby
Surrealist.configure do |config|
  config.camelize = true
  config.namespaces_nesting_level = 2
end
```
And by passing a hash:

`Surrealist.configure(camelize: true, include_root: true)`

These arguments will be applied to all calls of `#build_schema` and `#surrealize`.
If these methods will be called with arguments, they will be merged with respect to explicitly passed ones:

``` ruby
Surrealist.configure(camelize: true, include_root: true)

Something.new.surrealize(camelize: false)
# will result in Something.new.surrealize(camelize: false, include_root: true)
```

### Hash serialization

You can pass a hash to serializer and it will use the keys instead of methods.

``` ruby
class HashSerializer < Surrealist::Serializer
  json_schema { { string: String, int: Integer } }
end

HashSerializer.new(string: 'string', int: 4).surrealize
# => '{ "string": "string", "int": 4}'

HashSerializer.new(string: 'string', int: 'not int').surrealize
# => Surrealist::InvalidTypeError: Wrong type for key `int`. Expected Integer, got String.
```

### Bool and Any
If you have a parameter that is of boolean type, or if you don't care about the type, you
can use `Bool` and `Any` respectively.

``` ruby
class User
  include Surrealist

  json_schema do
    {
      age: Any,
      admin: Bool,
    }
  end
end
```

### Type Errors
`Surrealist::InvalidTypeError` is thrown if types (and dry-types) mismatch.

``` ruby
class CreditCard
  include Surrealist

  json_schema do
    { number: Integer }
  end

  def number
    'string'
  end
end

CreditCard.new.surrealize
# => Surrealist::InvalidTypeError: Wrong type for key `number`. Expected Integer, got String.
```

### Undefined methods in schema
`Surrealist::UndefinedMethodError` is thrown if a key defined in the schema does not have
a corresponding method defined in the object.

``` ruby
class Car
  include Surrealist

  json_schema do
    { weight: Integer }
  end
end

Car.new.surrealize
# => Surrealist::UndefinedMethodError: undefined method `weight' for #<Car:0x007f9bc1dc7fa8>. You have probably defined a key in the schema that doesn't have a corresponding method.
```

### Other notes
* nil values are allowed by default, so if you have, say, `age: String`, but the actual value is nil,
type check will be passed. If you want to be strict about `nil`s consider using `Dry::Types`.
* Surrealist [officially supports](https://travis-ci.org/nesaulov/surrealist) MRI Ruby 2.3+ but should be working on other platforms as well.

## Roadmap
Here is a list of features that are not implemented yet (contributions are welcome):
* Automatic endpoint documentation
* API for validating (contracts) without actually serializing to JSON (maybe with deserialization from JSON)

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/nesaulov/surrealist.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected
to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Credits
The icon was created by [Simon Child from Noun Project](https://thenounproject.com/term/salvador-dali/124566/) and is published under [Creative Commons License](https://creativecommons.org/licenses/by/3.0/us/)

## Authors
Created by [Nikita Esaulov](https://github.com/nesaulov) with help from [Alessandro Minali](https://github.com/AlessandroMinali) and [Alexey Bespalov](https://github.com/nulldef).

<a href="https://github.com/umbrellio/">
<img style="float: left;" src="https://umbrellio.github.io/Umbrellio/supported_by_umbrellio.svg" alt="Supported by Umbrellio" width="439" height="72">
</a>

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
