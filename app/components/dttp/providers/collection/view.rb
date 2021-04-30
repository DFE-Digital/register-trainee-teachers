# frozen_string_literal: true

module Dttp
  module Providers
    module Collection
      class View < ViewComponent::Base
        attr_reader :filters, :collection

        renders_many :filter_actions

        def initialize(filters:, collection:)
          @filters = filters
          @collection = collection
        end
      end
    end
  end
end
