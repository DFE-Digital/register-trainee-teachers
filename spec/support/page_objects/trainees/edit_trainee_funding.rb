# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditTraineeFunding < PageObjects::Base
      set_url "/trainees/{trainee_id}/funding/training-initiative/edit"

      element :training_initiative_radios, ".govuk-radios"
      element :continue_button, 'button.govuk-button[type="submit"]'
    end
  end
end
