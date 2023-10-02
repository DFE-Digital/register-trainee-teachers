# frozen_string_literal: true

module PageObjects
  module Funding
    class Show < PageObjects::Base
      set_url "funding"

      class FundingList < SitePrism::Section
        elements :items, "li"
      end

      section :funding_list, FundingList, ".funding-payment-list"
    end
  end
end
