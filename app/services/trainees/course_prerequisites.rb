# frozen_string_literal: true

module Trainees
  # What a draft trainee needs to complete before course details. Early years
  # teacher degree apprentices complete the Level 5 declaration first, as it
  # sets the course duration (and so the expected end date).
  class CoursePrerequisites
    def self.missing(trainee)
      [(:level_five_declaration if trainee.requires_level_five_declaration? && !level_five_declaration_complete?(trainee))].compact
    end

    def self.level_five_declaration_complete?(trainee)
      trainee.progress.level_five_declaration && !trainee.level_five_qualification.nil?
    end
  end
end
