# frozen_string_literal: true

class SchoolSearch
  include ServicePattern

  MIN_QUERY_LENGTH = 2
  DEFAULT_LIMIT = 15

  def initialize(query: nil, limit: DEFAULT_LIMIT, lead_schools_only: false)
    @query = StripPunctuation.call(string: query)
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

private

  attr_reader :query, :limit, :lead_schools_only
end
