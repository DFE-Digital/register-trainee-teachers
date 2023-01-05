# frozen_string_literal: true

module PageObjects
  module Reports
    class Index < PageObjects::Base
      set_url "/reports"

      element :performance_profiles_link, ".performance-profiles"
    end
  end
end
