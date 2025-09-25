# frozen_string_literal: true

module LeadPartnerResultNotice
  class View < ApplicationComponent
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

    def lead_partner_result_text
      return pluralised_lead_partner_result_text if remaining_search_count > 1

      t("components.lead_partner_result_notice.result_text", search_query:)
    end

  private

    attr_reader :search_limit, :search_count

    def total
      @total ||= search_count - search_limit
    end

    def pluralised_lead_partner_result_text
      t("components.lead_partner_result_notice.multiple_result_text", search_query:, remaining_search_count:)
    end
  end
end
