# frozen_string_literal: true

module PageObjects
  module Trainees
    class TrainingDetails < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{id}/training-details/edit"

      element :trainee_id, "#training-details-form-trainee-id-field"

      element :continue, "button[type='submit']"
    end
  end
end
