# frozen_string_literal: true

module PageObjects
  module Trainees
    class Edit < PageObjects::Base
      set_url "/trainees/{id}/edit"

      element :trainee_name, ".govuk-heading-xl"
      element :trn_status, ".govuk-tag.govuk-tag--turquoise"

      section :record_detail, PageObjects::Sections::Summaries::RecordDetail, ".record-details"
      section :programme_detail, PageObjects::Sections::Summaries::ProgrammeDetail, ".programme-details"
    end
  end
end
