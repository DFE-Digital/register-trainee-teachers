# frozen_string_literal: true

module PageObjects
  module Trainees
    class TrainingDetails < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{id}/training-details/edit"

      element :provider_trainee_id, "#training-details-form-provider-trainee-id-field"

      element :continue, "button[type='submit']"
    end
  end
end
