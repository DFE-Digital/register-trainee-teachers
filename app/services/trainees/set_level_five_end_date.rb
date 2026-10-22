# frozen_string_literal: true

module Trainees
  # After the Level 5 declaration is saved, fills in a draft EYTDA trainee's
  # expected end date from the course length: the ITT start date plus 2 years
  # (with a level 5 qualification) or 3 years (without). A date filled in this
  # way moves when the answer changes. A date the provider entered is kept; the
  # course details form checks it fits the course.
  class SetLevelFiveEndDate
    include ServicePattern

    def initialize(trainee:, previous_answer:)
      @trainee = trainee
      @previous_answer = previous_answer
    end

    def call
      return false unless trainee.draft? && trainee.requires_level_five_declaration?
      return false if trainee.level_five_qualification.nil? || trainee.itt_start_date.nil? || trainee.part_time?
      return false unless trainee.itt_end_date.nil? || trainee.itt_end_date == end_date_for(previous_answer)

      new_end_date = end_date_for(trainee.level_five_qualification)
      return false if trainee.itt_end_date == new_end_date

      trainee.update!(itt_end_date: new_end_date)
      true
    end

  private

    attr_reader :trainee, :previous_answer

    def end_date_for(answer)
      return if answer.nil?

      trainee.itt_start_date + TrainingRouteManager::LEVEL_FIVE_COURSE_YEARS.fetch(answer == true).years
    end
  end
end
