# frozen_string_literal: true

module HasDttpMapping
  def find_by_entity_id(id, mapping)
    mapping.select { |_key, value| value[:entity_id] == id }.keys&.first
  end
end
