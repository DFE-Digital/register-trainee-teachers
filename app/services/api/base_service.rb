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

    def sort_by
      params.fetch(:sort_by, SORT_BY)
    end

    def since
      params.fetch(:since, Date.new).to_date
    end
  end
end
