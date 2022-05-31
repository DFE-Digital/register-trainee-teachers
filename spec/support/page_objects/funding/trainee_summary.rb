# frozen_string_literal: true

module PageObjects
  module Funding
    class TraineeSummary < PageObjects::Base
      set_url "/funding/trainee-summary"
      element :export_link, ".app-trainee-export"
    end
  end
end
