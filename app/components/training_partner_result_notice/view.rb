# frozen_string_literal: true

module TrainingPartnerResultNotice
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

    def training_partner_result_text
      return pluralised_training_partner_result_text if remaining_search_count > 1

      t("components.training_partner_result_notice.result_text", search_query:)
    end

  private

    attr_reader :search_limit, :search_count

    def total
      @total ||= search_count - search_limit
    end

    def pluralised_training_partner_result_text
      t("components.training_partner_result_notice.multiple_result_text", search_query:, remaining_search_count:)
    end
  end
end
