# frozen_string_literal: true

module ProviderCard
  class View < ApplicationComponent
    include SanitizeHelper

    with_collection_parameter :provider

    attr_reader :provider

    def user_count
      if provider.respond_to?(:user_count)
        provider.user_count
      else
        provider.users.kept.count
      end
    end

    def initialize(provider:)
      @provider = provider
    end
  end
end
