# frozen_string_literal: true

module Dttp
  module Providers
    module Collection
      class View < ViewComponent::Base
        attr_reader :filters, :collection

        with_content_areas :filter_actions

        def initialize(filters:, collection:)
          @filters = filters
          @collection = collection
        end
      end
    end
  end
end
