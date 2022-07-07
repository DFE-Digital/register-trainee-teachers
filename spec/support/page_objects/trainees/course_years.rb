# frozen_string_literal: true

module PageObjects
  module Trainees
    class CourseYears < PageObjects::Base
      set_url "/trainees/{id}/course-years/edit"

      element :continue, "button[type='submit']"
    end
  end
end
