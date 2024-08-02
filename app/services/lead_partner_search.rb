# frozen_string_literal: true

class LeadPartnerSearch
  class Result
    attr_reader :lead_partners, :limit, :total_count

    def initialize(lead_partners:, limit:, total_count:)
      @lead_partners = lead_partners
      @limit = limit
      @total_count = total_count
    end
  end

  include ServicePattern

  MIN_QUERY_LENGTH = 2
  DEFAULT_LIMIT = 15

  def initialize(query: nil, limit: DEFAULT_LIMIT)
    @query = ReplaceAbbreviation.call(string: StripPunctuation.call(string: query))
    @limit = limit
  end

  def call
    Result.new(lead_partners: specified_lead_partners, limit: limit, total_count: total_count)
  end

  def all_lead_partners
    lead_partners = LeadPartner.all
    if query
      lead_partners = lead_partners
        .includes(:provider, :school)
        .where("name ilike ?", "%#{query}%")
        .or(LeadPartner.where("urn ilike ?", "%#{query}%"))
        .or(LeadPartner.where("ukprn ilike ?", "%#{query}%"))
    end
    lead_partners.reorder(:name)
  end

  def specified_lead_partners
    lead_partners = all_lead_partners
    lead_partners.limit(limit) if limit
  end

  def total_count
    all_lead_partners.count
  end

private

  attr_reader :query, :limit
end
