# Surrealist
[![Build Status](https://travis-ci.org/nesaulov/surrealist.svg?branch=master)](https://travis-ci.org/nesaulov/surrealist)
[![Coverage Status](https://coveralls.io/repos/github/nesaulov/surrealist/badge.svg?branch=master)](https://coveralls.io/github/nesaulov/surrealist?branch=master)
[![Inline docs](http://inch-ci.org/github/nesaulov/surrealist.svg?branch=master)](http://inch-ci.org/github/nesaulov/surrealist)
[![Gem Version](https://badge.fury.io/rb/surrealist.svg)](https://rubygems.org/gems/surrealist)

![Surrealist](surrealist-icon.png)
 
A gem that provides DSL for serialization of plain old Ruby objects to JSON in a declarative style
by defining a `json_schema`. It also provides a trivial type checking in the runtime before serialization.
[Yard documentation](http://www.rubydoc.info/github/nesaulov/surrealist/master)


## Motivation
A typical use case for this gem could be, for example, serializing a (decorated) object outside
of the view context. The schema is described through a hash, so you can build the structure
of serialized object independently of its methods and attributes, while also having possibility
to serialize nested objects and structures.

* [Installation](#installation)
* [Usage](#usage)
  * [Simple example](#simple-example)
  * [Nested structures](#nested-structures)
  * [Nested objects](#nested-objects)
  * [Usage with Dry::Types](#usage-with-drytypes)
  * [Build schema](#build-schema)
  * [Camelization](#camelization)
  * [Bool and Any](#bool-and-any)
  * [Type errors](#type-errors)
  * [Undefined methods in schema](#undefined-methods-in-schema)
  * [Other notes](#other-notes)
* [Contributing](#contributing)
* [Credits](#credits)
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
either a name of a method of the surrealizable object (or it's parents/mixins),
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
    {
      foo: String,
      bar: Integer,
    }
  end
 
  def foo
    'This is a string'
  end
 
  def bar
    42
  end
end
```

* Surrealize it.

``` ruby
Person.new.surrealize
# => '{ "foo": "This is a string", "bar" :42 }'
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
          level: Boolean,
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
      age:            Types::Coercible::Int,
      brand:          Types::Coercible::String,
      doors:          Types::Int.optional,
      horsepower:     Types::Strict::Int.constrained(gteq: 20),
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

### Build schema
If you don't need to dump the hash to json, you can use `#build_schema`
method on the instance. It calculates values and checks types, but returns
a hash instead of a JSON string. From the previous example:

``` ruby
Car.new.build_schema
# => { age: 7, brand: "Toyota", doors: nil, horsepower: 140, fuel_system: "Direct injection", previous_owner: "John Doe" }
```

### Camelization
If you need to have keys in camelBack, you can pass optional `camelize` argument
to `#surrealize`. From the previous example:

``` ruby
Car.new.surrealize(camelize: true)
# => '{ "age": 7, "brand": "Toyota", "doors": null, "horsepower": 140, "fuelSystem": "Direct injection", "previousOwner": "John Doe" }'
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
* Surrealist requires ruby of version 2.2 and higher.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/nesaulov/surrealist.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected
to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Credits
The icon was created by [Simon Child from Noun Project](https://thenounproject.com/term/salvador-dali/124566/) and is published under [Creative Commons License](https://creativecommons.org/licenses/by/3.0/us/)

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
