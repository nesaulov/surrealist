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

rom = ROM.container(:memory) do |conf|
  conf.register_mapper(ItemsMapper)
  conf.relation(:items) do
    def all; as(:item_obj).to_a; end
  end
  conf.commands(:items) do
    define(:create)
  end
end

rom.command(:items).create.call(name: 'testing rom')
