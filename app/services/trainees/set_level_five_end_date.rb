# frozen_string_literal: true

module Trainees
  # After the Level 5 declaration is saved, fills in a draft EYTDA trainee's
  # expected end date from the usual course length: the ITT start date plus
  # 2 years for Year 2 entry, or 33 months otherwise. A date filled in this way
  # moves when the answer changes, including a date filled in before the first
  # answer (33 months). A date the provider entered is kept; the course details
  # form checks it fits the course.
  class SetLevelFiveEndDate
    include ServicePattern

    def initialize(trainee:, previous_answer:)
      @trainee = trainee
      @previous_answer = previous_answer
    end

    def call
      return false unless trainee.draft? && trainee.requires_level_five_declaration?
      return false if trainee.level_five_qualification.nil? || trainee.itt_start_date.nil?
      return false unless trainee.itt_end_date.nil? || trainee.itt_end_date == end_date_for(previous_answer)

      new_end_date = end_date_for(trainee.level_five_qualification)
      return false if trainee.itt_end_date == new_end_date

      trainee.update!(itt_end_date: new_end_date)
      true
    end

  private

    attr_reader :trainee, :previous_answer

    # No answer yet fills in the standard length, the same as No.
    def end_date_for(answer)
      trainee.itt_start_date + TrainingRouteManager::LEVEL_FIVE_COURSE_MONTHS.fetch(answer == true).months
    end
  end
end
