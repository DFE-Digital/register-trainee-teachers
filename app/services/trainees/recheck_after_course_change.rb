# frozen_string_literal: true

module Trainees
  # When a draft trainee's course details change, the sections that depend on
  # the course are checked again (funding_eligibility_step flag). Runs before the
  # trainee is saved (Trainee before_update), so every course details form and
  # the route change are covered:
  #   - funding: if started, every funding answer (eligibility, training
  #     initiative, funding type) is cleared and the section reset, so the
  #     provider adds it again. The reason shown is the route, the subject, or
  #     the course details.
  #   - training partner and employing school, on routes with an employing school:
  #     if complete, back to in progress to confirm again
  # Entering course details for the first time isn't a change.
  class RecheckAfterCourseChange
    include ServicePattern

    COURSE_ATTRIBUTES = %w[
      training_route
      course_uuid
      course_education_phase
      course_subject_one
      course_subject_two
      course_subject_three
      course_allocation_subject_id
      course_min_age
      course_max_age
      itt_start_date
      itt_end_date
      study_mode
      start_academic_cycle_id
    ].freeze

    FUNDING_CHOICES = %w[training_initiative applying_for_bursary applying_for_scholarship applying_for_grant bursary_tier].freeze
    FUNDING_ANSWERS = (FUNDING_CHOICES + %w[funding_eligibility]).freeze

    # Clears every funding answer so the provider starts the funding section again.
    def self.clear_funding(trainee, reason:)
      trainee.assign_attributes(FUNDING_ANSWERS.index_with { nil })
      trainee.progress.funding = false
      trainee.progress.clear_funding_recheck
      trainee.progress.funding_removed_reason = reason
    end

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      return false unless FeatureService.enabled?(:funding_eligibility_step)
      return false unless trainee.persisted? && trainee.draft? && course_changed?

      recheck_funding
      recheck_schools
      true
    end

  private

    attr_reader :trainee

    def course_changed?
      COURSE_ATTRIBUTES.any? do |attribute|
        trainee.will_save_change_to_attribute?(attribute) && trainee.attribute_in_database(attribute).present?
      end
    end

    def recheck_funding
      return unless funding_removed? || funding_started_before?

      self.class.clear_funding(trainee, reason: removal_reason)
    end

    def removal_reason
      return "route" if trainee.will_save_change_to_training_route?
      return "subject" if funding_removed?

      "course_details"
    end

    def recheck_schools
      return unless trainee.requires_employing_school? || trainee.requires_assessment_only_employing_school?
      return unless trainee.progress.schools

      trainee.progress.schools = false
      trainee.progress.schools_recheck_course_details = true
    end

    # The funding choices were cleared with the course (CourseFormHelpers, RouteDataManager).
    def funding_removed?
      FUNDING_CHOICES.any? do |attribute|
        !trainee.attribute_in_database(attribute).nil? && trainee.public_send(attribute).nil?
      end
    end

    def funding_started_before?
      (FUNDING_CHOICES + %w[funding_eligibility]).any? { |attribute| !trainee.attribute_in_database(attribute).nil? } ||
        trainee.attribute_in_database("progress")&.funding
    end
  end
end
