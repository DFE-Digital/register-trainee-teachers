# frozen_string_literal: true

module HasDttpMapping
  def find_by_entity_id(id, mapping)
    mapping.select { |_key, value| value[:entity_id] == id }.keys&.first
  end

  def non_uk_degree?
    country && united_kingdom_countries.exclude?(country)
  end

  def united_kingdom_countries
    [
      Register::CodeSets::Countries::UNITED_KINGDOM,
      Register::CodeSets::Countries::ENGLAND,
      Register::CodeSets::Countries::NORTHERN_IRELAND,
      Register::CodeSets::Countries::SCOTLAND,
      Register::CodeSets::Countries::UNITED_KINGDOM_NOT_OTHERWISE_SPECIFIED,
      Register::CodeSets::Countries::WALES,
    ]
  end
end
