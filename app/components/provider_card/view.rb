# frozen_string_literal: true

module ProviderCard
  class View < GovukComponent::Base
    include SanitizeHelper

    with_collection_parameter :provider

    attr_reader :provider

    def initialize(provider:)
      @provider = provider
    end
  end
end
