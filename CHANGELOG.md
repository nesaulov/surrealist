# 1.1.2

## Fixed
* Bug with inheritance and mixins ([@nesaulov][]) [#93](https://github.com/nesaulov/surrealist/pull/93)

# 1.1.1

## Fixed
* Bug with several serializations in a row ([@past-one][]) [#90](https://github.com/nesaulov/surrealist/pull/90)

# 1.1.0

## Added
* Configuration of default serialization params ([@nesaulov][]) [#77](https://github.com/nesaulov/surrealist/pull/77)
* DSL for custom serializers context ([@nesaulov][]) [#80](https://github.com/nesaulov/surrealist/pull/80)

## Fixed
* Fix failing serialization with sequel & custom serializers ([@azhi][]) [#84](https://github.com/nesaulov/surrealist/pull/84)

## Miscellaneous
* Pin Oj version to 3.4.0 [#79](https://github.com/nesaulov/surrealist/pull/79)

# 1.0.0

## Added
* `#build_schema` for collections from `Surrealist::Serializer` ([@nesaulov][]) [#74](https://github.com/nesaulov/surrealist/pull/74)
* Oj dependency
* Multiple serializers API ([@nulldef][]) [#66](https://github.com/nesaulov/surrealist/pull/66)

## Miscellaneous
* Benchmarks for Surrealist vs AMS
* A lot of memory & performance optimizations ([@nesaulov][]) [#64](https://github.com/nesaulov/surrealist/pull/64)

# 0.4.0

## Added
* Introduce an abstract serializer class ([@nesaulov][]) [#61](https://github.com/nesaulov/surrealist/pull/61)
* Full integration for Sequel ([@nesaulov][]) [#47](https://github.com/nesaulov/surrealist/pull/47)
* Integration for ROM 4.x ([@nesaulov][]) [#56](https://github.com/nesaulov/surrealist/pull/56)
* Ruby 2.5 support ([@nesaulov][]) [#57](https://github.com/nesaulov/surrealist/pull/57)

## Miscellaneous
* Memory & performance optimizations ([@nesaulov][]) [#51](https://github.com/nesaulov/surrealist/pull/51)
* Refactorings ([@nulldef][]) [#55](https://github.com/nesaulov/surrealist/pull/55)

# 0.3.0

## Added
* Full integration for ActiveRecord ([@nesaulov][], [@AlessandroMinali][]) [#37](https://github.com/nesaulov/surrealist/pull/37)
* Full integration for ROM <= 3 ([@nesaulov][], [@AlessandroMinali][]) [#37](https://github.com/nesaulov/surrealist/pull/37)
* `root` optional argument ([@chrisatanasian][]) [#32](https://github.com/nesaulov/surrealist/pull/32)
* Nested records surrealization ([@AlessandroMinali][]) [#34](https://github.com/nesaulov/surrealist/pull/34)

## Fixed
* Dependencies update ([@nesaulov][]) [#48](https://github.com/nesaulov/surrealist/pull/48)

# 0.2.0
## Added
* `delegate_surrealization_to` class method
* `include_namespaces` optional argument
* `namespaces_nesting_level` optional argument
* `Surrealist.surrealize_collection` method for collection serialization

# 0.1.4
## Added
* Optional `include_root` argument to wrap schema in a root key. [#15](https://github.com/nesaulov/surrealist/pull/15)
## Fixed
* Performance of schema cloning.
## Changed
* `Boolean` module renamed to `Bool`.

# 0.1.2
## Added
* `Any` module for skipping type checks.
* Optional `camelize` argument to convert keys to camelBacks.

# 0.1.0
## Fixed
* Fix schema mutability issue.
## Changed
* Change `schema` class method to `json_schema` due to compatibility issues with other gems.

# 0.0.6
## Added
* `build_schema` instance method that builds hash from the schema without serializing it to json.
## Changed
* Allow nil values by default.
* Allow nested objects.

[@nesaulov]: https://github.com/nesaulov
[@AlessandroMinali]: https://github.com/AlessandroMinali
[@nulldef]: https://github.com/nulldef
[@azhi]: https://github.com/azhi
[@chrisatanasian]: https://github.com/chrisatanasian
[@past-one]: https://github.com/past-one

