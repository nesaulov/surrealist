# frozen_string_literal: true

# A module that is included in +TrueClass+ and +FalseClass+ for boolean type-checks.
module Boolean; end
# TrueClass monkey-patch.
class TrueClass; include Boolean; end
# FalseClass monkey-patch.
class FalseClass; include Boolean; end
