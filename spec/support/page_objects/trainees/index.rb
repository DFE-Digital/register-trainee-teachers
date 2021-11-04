# frozen_string_literal: true

module PageObjects
  module Trainees
    class Index < PageObjects::Base
      set_url "/trainees"

      element :page_heading, ".govuk-heading-xl"

      element :add_trainee_link, "a", text: "Create a trainee record"

      element :draft_trainee_data, ".app-draft-records"

      elements :trainee_data, ".application-record-card"

      elements :trainee_name, ".application-record-card .govuk-link"

      element :filter_tags, ".moj-filter-tags"
      element :clear_filters_link, "a", text: "Clear"
      element :apply_filters, "input[type='submit'][value='Apply filters']"

      element :text_search, "#text_search"
      element :early_years_checkbox, "#level-early_years"
      element :assessment_only_checkbox, "#training_route-assessment_only"
      element :draft_checkbox, "#state-draft"
      element :imported_from_apply_checkbox, "#record_source-apply"
      element :provider_led_postgrad_checkbox, "#training_route-provider_led_postgrad"
      element :subject, "#subject"
      element :provider_filter, "#provider"

      element :export_link, ".app-trainee-export"

      element :no_records_found, "h2", text: "No records found"
    end
  end
end
