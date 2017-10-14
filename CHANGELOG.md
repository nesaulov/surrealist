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



