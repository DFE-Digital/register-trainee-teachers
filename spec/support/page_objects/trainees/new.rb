module PageObjects
  module Trainees
    class New < PageObjects::Base
      set_url "/trainees/new"

      element :page_title, ".govuk-heading-xl"

      element :trainee_id_input, "#trainee-trainee-id-field"
      element :trainee_first_names_input, "#trainee-first-names-field"
      element :trainee_last_name_input, "#trainee-last-name-field"

      element :continue_button, 'input.govuk-button[type="submit"]'
    end
  end
end
