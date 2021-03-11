# frozen_string_literal: true

module PageObjects
  module Trainees
    module Diversities
      class ConfirmDetails < PageObjects::Trainees::ConfirmDetails
        set_url "/trainees/{id}/diversity/confirm"

        def edit_link_for(section)
          within(".govuk-summary-list__row.#{section}") do
            find(".govuk-link")
          end
        end
      end
    end
  end
end
