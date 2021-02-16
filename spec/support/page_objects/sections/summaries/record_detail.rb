# frozen_string_literal: true

require_relative "../base"

module PageObjects
  module Sections
    module Summaries
      class RecordDetail < PageObjects::Sections::Base
        element :trainee_id_row, ".govuk-summary-list__row.trainee-id"
        element :trn_submission_row, ".govuk-summary-list__row.submitted-for-trn"
        element :last_updated_row, ".govuk-summary-list__row.last-updated"
        element :record_created_row, ".govuk-summary-list__row.record-created"
        element :start_date_row, ".govuk-summary-list__row.trainee-start-date"
      end
    end
  end
end
