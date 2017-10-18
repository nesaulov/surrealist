require 'rom'

class Item
  include Surrealist

  json_schema { { name: String } }

  attr_reader :id, :name

  def initialize(attributes)
    @id, @name = attributes.values_at(:id, :name)
  end
end

class ItemsMapper < ROM::Mapper
  register_as :item_obj
  relation :items
  model Item
end
