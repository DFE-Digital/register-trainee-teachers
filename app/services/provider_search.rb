# frozen_string_literal: true

class ProviderSearch
  class Result
    attr_reader :providers, :limit

    def initialize(providers:, limit:)
      @providers = providers
      @limit = limit
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
    Result.new(providers: specified_providers, limit: limit)
  end

  def specified_providers
    providers = Provider
    providers = providers.search(query) if query
    providers = providers.limit(limit) if limit
    providers.reorder(:name)
  end

private

  attr_reader :query, :limit
end
