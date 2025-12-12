# frozen_string_literal: true

class TrainingPartnerSearch
  class Result
    attr_reader :training_partners, :limit, :total_count

    def initialize(training_partners:, limit:, total_count:)
      @training_partners = training_partners
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
    Result.new(training_partners: specified_training_partners, limit: limit, total_count: total_count)
  end

  def all_training_partners
    training_partners = TrainingPartner.kept
    if query
      training_partners = training_partners
        .includes(:provider, :school)
        .where("training_partners.name ilike ?", "%#{query}%")
        .or(TrainingPartner.kept.where("training_partners.urn ilike ?", "%#{query}%"))
        .or(TrainingPartner.kept.where("training_partners.ukprn ilike ?", "%#{query}%"))
        .or(TrainingPartner.kept.where(id:
          TrainingPartner.kept.joins(:school).where(school: School.where("postcode ilike ?", "%#{query}%")).select(:id)))

    end
    training_partners.reorder(:name)
  end

  def specified_training_partners
    training_partners = all_training_partners
    training_partners.limit(limit) if limit
  end

  def total_count
    all_training_partners.count
  end

private

  attr_reader :query, :limit
end
