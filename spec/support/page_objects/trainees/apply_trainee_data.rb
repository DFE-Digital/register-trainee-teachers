# frozen_string_literal: true

module PageObjects
  module Trainees
    class ApplyTraineeData < PageObjects::Base
      set_url "/trainees/{id}/apply-trainee-data/edit"

      element :full_name_change_link, ".full-name a"
      element :i_have_reviewed_checkbox, "#apply-trainee-data-form-mark-as-reviewed-1-field"
      element :continue, "input[name='commit'][value='Continue']"
    end
  end
end
