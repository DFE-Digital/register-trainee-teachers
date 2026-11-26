# frozen_string_literal: true

module Trainees
  # When a draft EYTDA trainee's Level 5 declaration answer changes (Yes to No,
  # or No to Yes), the course length and the funded years change, so:
  #   - course details, if completed or the course dates entered, go back to
  #     in progress to confirm again (the expected end date must fit the length)
  #   - funding, if it had been started, is reset: every funding answer
  #     (eligibility, training initiative, funding type) is cleared, so the
  #     provider adds it again
  #   - a confirmed longer course (extended_course_confirmed) is cleared, so the
  #     provider confirms it again against the new usual length
  # The same answer saved again isn't a change. The course dates and funding can
  # be added before the first answer, using the standard length, so after the
  # first answer:
  #   - course details go back to in progress if the provider's end date is
  #     longer than the usual length the answer sets, so they confirm it
  #   - funding, if started, is reset for Year 2 entry, as the funded years change
  # Runs after the declaration is saved and the expected end date is moved
  # (Trainees::SetLevelFiveEndDate). Moving the date can already have cleared the
  # funding as a course details change, so whether funding had been started is
  # taken from before the save, and the reason shown is the level 5 declaration.
  class RecheckAfterLevelFiveChange
    include ServicePattern

    def self.funding_started?(trainee)
      trainee.progress.funding ||
        ProgressService.call(validator: ::Funding::FormValidator.new(trainee), progress_value: false).started?
    end

    def initialize(trainee:, previous_answer:, funding_started_before: false)
      @trainee = trainee
      @previous_answer = previous_answer
      @funding_started_before = funding_started_before
    end

    def call
      return false unless trainee.draft? && trainee.requires_level_five_declaration?
      return false if trainee.level_five_qualification.nil?
      return false if previous_answer == trainee.level_five_qualification

      course_details, funding, declaration = previous_answer.nil? ? first_answer_changes : answer_changes
      return false unless course_details || funding || declaration

      # The usual course length changed, so a longer course is confirmed again.
      trainee.extended_course_confirmed = false
      recheck_course_details if course_details
      RecheckAfterCourseChange.clear_funding(trainee, reason: "level_five_declaration") if funding
      trainee.save!
      true
    end

  private

    attr_reader :trainee, :previous_answer, :funding_started_before

    # What to check again: course details, funding, and a confirmed longer course.
    def answer_changes
      [recheck_course_details?, reset_funding?, trainee.extended_course_confirmed]
    end

    # Before the first answer, the course used the standard length and the
    # standard funded years, and a longer course couldn't be confirmed.
    def first_answer_changes
      [course_longer_than_usual?, trainee.level_five_qualification == true && reset_funding?, false]
    end

    # Before the first answer there's no usual length to confirm a longer course against.
    def course_longer_than_usual?
      return false unless trainee.itt_start_date && trainee.itt_end_date

      trainee.itt_end_date > trainee.itt_start_date + trainee.level_five_course_months.months
    end

    def recheck_course_details?
      trainee.progress.course_details || course_dates_entered?
    end

    def reset_funding?
      trainee.requires_funding? && (funding_started_before || self.class.funding_started?(trainee))
    end

    def recheck_course_details
      trainee.progress.course_details = false
      trainee.progress.course_details_recheck_level_five_declaration = true
    end

    # The subject is filled in with the EYTDA route, so the dates show course details were entered.
    def course_dates_entered?
      trainee.itt_start_date.present? || trainee.itt_end_date.present?
    end
  end
end
