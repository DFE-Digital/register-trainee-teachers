# frozen_string_literal: true

module SystemAdmin
  module Dttp
    module Providers
      class Filter
        include ServicePattern

        def initialize(providers:, params:)
          @providers = providers
          @filters = params.to_h.with_indifferent_access.slice(:text_search)
        end

        def call
          return providers if filters.blank?

          filter_records
        end

        private

        attr_reader :providers, :filters

        def text_search(providers, text_search)
          return providers if text_search.blank?

          providers.search_by_name(text_search)
        end

        def filter_records
          text_search(providers, filters[:text_search])
        end
      end
    end
  end
end
