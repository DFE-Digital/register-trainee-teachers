# frozen_string_literal: true

module PageObjects
  module Helpers
    def set_date_fields(field_prefix, date_string)
      if date_string.present?
        day, month, year = date_string.split("/")
      else
        #  Allows us to set date fields to blank
        day = month = year = ""
      end
      public_send("#{field_prefix}_day").set(day)
      public_send("#{field_prefix}_month").set(month)
      public_send("#{field_prefix}_year").set(year)
    end
  end

  class Base < SitePrism::Page; end

  class Accessibility < PageObjects::Base
    set_url "/accessibility"

    element :page_heading, ".govuk-heading-l"
  end

  class PrivacyPolicy < PageObjects::Base
    set_url "/privacy-policy"

    element :page_heading, ".govuk-heading-l"
  end
end
