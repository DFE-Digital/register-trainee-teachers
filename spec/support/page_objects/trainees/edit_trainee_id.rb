# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditTraineeId < PageObjects::Base
      set_url "/trainees/{trainee_id}/trainee_id/edit"

      element :trainee_id_input, "#trainee-trainee-id-field"
      element :continue, ".govuk-button"
    end
  end
end
