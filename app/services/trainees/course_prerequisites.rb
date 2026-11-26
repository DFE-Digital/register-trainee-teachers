# frozen_string_literal: true

module Trainees
  # What a draft trainee needs to complete before course details. Nothing at
  # the moment: early years teacher degree apprentices can enter the course
  # dates before the Level 5 declaration. The end date is filled in from the
  # standard length, and moves when the declaration is answered
  # (Trainees::SetLevelFiveEndDate).
  class CoursePrerequisites
    def self.missing(_trainee)
      []
    end
  end
end
