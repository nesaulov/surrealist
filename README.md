# Surrealist
[![Build Status](https://travis-ci.com/nesaulov/surrealist.svg?token=UM7SJoXQ7Y56NHBpib7v&branch=master)](https://travis-ci.com/nesaulov/surrealist)
[![Coverage Status](https://coveralls.io/repos/github/nesaulov/surrealist/badge.svg?branch=master)](https://coveralls.io/github/nesaulov/surrealist?branch=master)

A gem that provides DSL for serialization of plain old Ruby objects to JSON in a declarative style
by defining a `schema`. It also provides a trivial type checking in the runtime before serialization.  

## Motivation
A typical use case for this gem could be, for example, serializing a decorated object outside of the view context.
 
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
or - in case value is a hash - a symbol: to build nested JSON structures.
Every value of the hash should be a constant that represents a Ruby class,
that will be used for type-checks.

### Simple example
* Include Surrealist in your class.
* Define a schema with methods that need to be serialized.
``` ruby
class Person
  include Surrealist
  
  schema do
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
# => "{\"foo\":\"This is a string\",\"bar\":42}"
```

### Nested structures
``` ruby
class Person
  include Surrealist

  schema do
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
# => "{\"foo\":\"Some string\",\"name\":\"John Doe\",\"nested\":{\"at\":{\"any\":42,\"level\":true}}}"
```

### Type Errors
`Surrealist::InvalidTypeError` is thrown if types mismatch.

``` ruby
class CreditCard
  include Surrealist

  schema do
    { number: Integer }
  end

  def number; 'string'; end
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

  schema do
    { weight: Integer }
  end
end

Car.new.surrealize
# => Surrealist::UndefinedMethodError: undefined method `weight' for #<Car:0x007f9bc1dc7fa8>. You have probably defined a key in the schema that doesn't have a corresponding method.
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nesaulov/surrealist.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected
to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
