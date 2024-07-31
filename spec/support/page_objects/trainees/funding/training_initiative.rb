# frozen_string_literal: true

module PageObjects
  module Trainees
    module Funding
      class TrainingInitiative < PageObjects::Base
        set_url "/trainees/{id}/funding/training-initiative/edit"

        element :now_teach, "#funding-training-initiatives-form-training-initiative-now-teach-field"

        element :submit_button, "button[type='submit']"
      end
    end
  end
end
