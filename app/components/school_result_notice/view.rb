# frozen_string_literal: true

module SchoolResultNotice
  class View < ViewComponent::Base
    attr_reader :search_query

    def initialize(search_query:, search_limit:, search_count:)
      @search_query = search_query
      @search_limit = search_limit
      @search_count = search_count
    end

    def render?
      total.positive?
    end

    def remaining_search_count
      total
    end

    def school_result_text
      return pluralised_school_result_text if remaining_search_count > 1

      t("components.school_result_notice.result_text", search_query:)
    end

  private

    attr_reader :search_limit, :search_count

    def total
      @total ||= search_count - search_limit
    end

    def pluralised_school_result_text
      t("components.school_result_notice.multiple_result_text", search_query:, remaining_search_count:)
    end
  end
end
