# frozen_string_literal: true

module PageObjects
  module Trainees
    class EditTraineeId < PageObjects::Base
      set_url "/trainees/{trainee_id}/trainee-id/edit"

      element :trainee_id_input, "#trainee-id-form-trainee-id-field"
      element :continue, "input[name='commit']"
    end
  end
end
