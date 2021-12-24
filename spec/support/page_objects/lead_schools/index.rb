# frozen_string_literal: true

require_relative "../sections/provider_card"

module PageObjects
  module LeadSchools
    class Index < PageObjects::Base
      set_url "/system-admin/lead-schools"
    end
  end
end
