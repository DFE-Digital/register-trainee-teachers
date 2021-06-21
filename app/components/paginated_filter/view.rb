# frozen_string_literal: true

module PaginatedFilter
  class View < ViewComponent::Base
    attr_reader :filters, :collection, :filter_params

    renders_many :filter_actions
    renders_many :filter_options

    def initialize(filters:, collection:, filter_params:)
      @filters = filters
      @collection = collection
      @filter_params = filter_params
    end
  end
end
