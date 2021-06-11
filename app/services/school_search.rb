# frozen_string_literal: true

class SchoolSearch
  include ServicePattern

  attr_reader :query, :limit, :lead_schools_only

  MIN_QUERY_LENGTH = 2
  DEFAULT_LIMIT = 15

  def initialize(query: nil, limit: DEFAULT_LIMIT, lead_schools_only: false)
    @query = query&.gsub(/['’.“”"]/, "")&.gsub(/[^0-9A-Za-z\s]/, " ")
    @limit = limit
    @lead_schools_only = lead_schools_only
  end

  def call
    schools = School.open
    schools = schools.search(query) if query
    schools = schools.limit(limit) if limit
    schools = schools.lead_only if lead_schools_only
    schools.reorder(:name)
  end
end
