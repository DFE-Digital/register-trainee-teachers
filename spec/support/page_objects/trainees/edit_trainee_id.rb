# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditTraineeId < PageObjects::Base
      set_url "/trainees/{trainee_id}/trainee-id/edit"

      element :trainee_id_input, "#training-details-form-trainee-id-field"
      element :continue, ".govuk-button"
    end
  end
end
