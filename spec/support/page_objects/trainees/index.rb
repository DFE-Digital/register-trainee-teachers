# frozen_string_literal: true

module PageObjects
  module Trainees
    class Base < PageObjects::Base
      element :page_heading, ".govuk-heading-l"

      element :add_trainee_link, "a", text: "Create a trainee record"

      elements :trainee_data, ".application-record-card"

      elements :trainee_name, ".application-record-card .govuk-link"

      element :filter_tags, ".moj-filter-tags"
      element :clear_filters_link, "a", text: "Clear"
      element :apply_filters, "input[type='submit'][value='Apply filters']"

      element :text_search, "#text_search"
      element :early_years_checkbox, "#level-early_years"
      element :complete_checkbox, "#record_completion-complete"
      element :incomplete_checkbox, "#record_completion-incomplete"
      element :assessment_only_checkbox, "#training_route-assessment_only"
      element :imported_from_apply_checkbox, "#record_source-apply"
      element :imported_from_dttp_checkbox, "#record_source-dttp"
      element :provider_led_postgrad_checkbox, "#training_route-provider_led_postgrad"
      element :subject, "#subject"
      element :provider_filter, "#provider"

      element :export_link, ".app-trainee-export"

      element :zero_records_found, "h2", text: "No records found"
    end

    class Index < Base
      set_url "/trainees"

      element :in_training_checkbox, "#status-in_training"
      element :withdrawn_checkbox, "#status-withdrawn"
    end

    class Drafts < Base
      set_url "/drafts"
    end
  end
end
