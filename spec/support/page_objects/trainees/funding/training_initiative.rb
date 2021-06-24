# frozen_string_literal: true

module PageObjects
  module Trainees
    module Funding
      class TrainingInitiative < PageObjects::Base
        set_url "/trainees/{id}/funding/training-initiative/edit"

        element :transition_to_teach, "#funding-training-initiatives-form-training-initiative-transition-to-teach-field"

        element :submit_button, "button[type='submit']"
      end
    end
  end
end
