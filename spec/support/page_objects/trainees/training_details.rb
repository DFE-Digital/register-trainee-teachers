# frozen_string_literal: true

module PageObjects
  module Trainees
    class TrainingDetails < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{id}/training-details"

      element :trainee_id, "#trainee-trainee-id-field"
      element :submit_button, "input[name='commit']"
    end
  end
end
