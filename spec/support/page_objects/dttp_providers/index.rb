# frozen_string_literal: true

require_relative "../sections/provider_card"

module PageObjects
  module DttpProviders
    class Index < PageObjects::Base
      set_url "/system-admin/dttp_providers"
    end
  end
end
