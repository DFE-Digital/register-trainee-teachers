# frozen_string_literal: true

module PageObjects
  module Trainees
    class Index < PageObjects::Base
      set_url "/trainees"

      element :page_heading, ".govuk-heading-xl"

      element :add_trainee_link, "a", text: "Add a trainee"

      elements :trainee_data, ".app-application-card"

      elements :trainee_name, ".app-application-card .govuk-link"

      element :filter_tags, ".moj-filter-tags"
      element :clear_filters_link, "a", text: "Clear"
      element :apply_filters, "input[name='commit']"

      element :text_search, "#text_search"
      element :assessment_only_checkbox, "#record_type-assessment_only"
      element :provider_led_checkbox, "#record_type-provider_led"
      element :subject, "#subject"
    end
  end
end
