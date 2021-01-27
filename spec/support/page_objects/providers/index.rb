# frozen_string_literal: true

require_relative "../sections/provider_card"

module PageObjects
  module Providers
    class Index < PageObjects::Base
      set_url "/system-admin/providers"

      element :add_provider_link, "a", text: "Add a provider"

      section :provider_card, PageObjects::Sections::ProviderCard, ".provider-card"
    end
  end
end
