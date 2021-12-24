# frozen_string_literal: true

require_relative "../sections/provider_card"

module PageObjects
  module Schools
    class Index < PageObjects::Base
      set_url "/system-admin/schools"
    end
  end
end
