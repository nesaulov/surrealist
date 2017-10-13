VALID_PARAMS = [
  { camelize: true,  include_namespaces: true, include_root: true, root: '', namespaces_nesting_level: 3 },
  { camelize: false, include_namespaces: true, include_root: true, root: 'root', namespaces_nesting_level: 3 },
  { camelize: false, include_namespaces: false, include_root: true, root: nil, namespaces_nesting_level: 3 },
  { camelize: false, include_namespaces: false, include_root: false, root: '', namespaces_nesting_level: 3 },
  { camelize: true,  include_namespaces: false, include_root: false, root: 'root', namespaces_nesting_level: 3 },
  { camelize: true,  include_namespaces: true, include_root: false, root: nil, namespaces_nesting_level: 3 },
  { camelize: true,  include_namespaces: false, include_root: true, root: '', namespaces_nesting_level: 3 },
  { camelize: true,  include_namespaces: false, include_root: true, root: 'root', namespaces_nesting_level: 435 },
  { camelize: true,  include_namespaces: false, include_root: true, root: nil, namespaces_nesting_level: 666 },
].freeze

INVALID_PARAMS = [
  { camelize: 'NO', include_namespaces: false, include_root: true, root: '', namespaces_nesting_level: 3 },
  { camelize: true, include_namespaces: 'false', include_root: true, root: 'root', namespaces_nesting_level: 3 },
  { camelize: true, include_namespaces: false, include_root: true, root: nil, namespaces_nesting_level: 0 },
  { camelize: true, include_namespaces: false, include_root: false, root: '', namespaces_nesting_level: -3 },
  { camelize: true, include_namespaces: false, include_root: 'yep', root: 'root', namespaces_nesting_level: 3 },
  { camelize: 'NO', include_namespaces: false, include_root: true, root: nil, namespaces_nesting_level: '3' },
  { camelize: 'NO', include_namespaces: false, include_root: true, root: '', namespaces_nesting_level: 3.14 },
  { camelize: Integer, include_namespaces: false, include_root: true, root: 'root', namespaces_nesting_level: 3 },
  { camelize: 'NO', include_namespaces: 'no', include_root: true, root: nil, namespaces_nesting_level: '3.4' },
  { camelize: 'f', include_namespaces: false, include_root: 't', root: '', namespaces_nesting_level: true },
].freeze
