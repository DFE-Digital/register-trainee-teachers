# frozen_string_literal: true

module PageObjects
  module Trainees
    class ConfirmTrainingDetails < PageObjects::Base
      set_url "/trainees/{id}/training-details/confirm"

      element :continue, "input[name='commit']"
    end
  end
end
