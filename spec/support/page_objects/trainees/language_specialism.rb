# frozen_string_literal: true

module PageObjects
  module Trainees
    class LanguageSpecialism < PageObjects::Base
      include PageObjects::Helpers

      set_url "/trainees/{trainee_id}/language-specialisms/edit"

      element :language_select_one, "select#language-specialisms-form-course-subject-one-field"
      element :language_select_two, "select#language-specialisms-form-course-subject-two-field"
      element :language_select_three, "select#language-specialisms-form-course-subject-three-field"

      element :submit_button, "button[type='submit']"
    end
  end
end
