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

  class PrivacyNotice < PageObjects::Base
    set_url "/privacy-notice"

    element :page_heading, ".govuk-heading-l"
  end

  class ApiDocs < PageObjects::Base
    set_url "/api-docs/"

    element :page_heading, "h1"
  end

  class CsvDocs < PageObjects::Base
    set_url "/csv-docs/"

    element :page_heading, "h1"
  end

  class ReferenceDataPage < PageObjects::Base
    set_url "/reference-data/"

    element :page_heading, "h1"

    element :v20250_link, "a", text: "v2025.0"

    element :course_age_range_link, "a", text: "Course Age Range"
    element :course_age_range_heading, "h1", text: "Course Age Range"
    element :course_age_range_download_link, "a", text: "Download valid entries as a CSV file"
  end

  class ServiceUpdates < PageObjects::Base
    set_url "/service-updates"

    element :page_heading, ".govuk-heading-xl"
  end

  class Guidance < PageObjects::Base
    set_url "/guidance"

    element :page_heading, ".govuk-heading-l"
  end

  class Cookies < PageObjects::Base
    set_url "/cookies"

    element :page_heading, ".govuk-heading-xl"
  end
end
