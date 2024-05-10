# frozen_string_literal: true

module Api
  class BaseService
    include ServicePattern
    include Config

    def initialize(params = {})
      @params = params
    end

  private

    attr_reader :params

    def pagination_per_page
      params.fetch(:per_page, PAGINATION_PER_PAGE).to_i
    end

    def page
      params.fetch(:page, 1).to_i
    end

    def sort_order
      params.fetch(:sort_order, SORT_ORDER)
    end

    def since
      params.fetch(:since, DateTime.iso8601)
    end
  end
end
