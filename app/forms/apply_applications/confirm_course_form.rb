# frozen_string_literal: true

module ApplyApplications
  class ConfirmCourseForm
    include ActiveModel::Model
    include CourseFormHelpers

    FIELDS = %i[
      uuid
      mark_as_reviewed
    ].freeze

    attr_accessor(*FIELDS, :trainee, :specialisms, :params)

    delegate :id, :persisted?, to: :trainee

    def initialize(trainee, specialisms, params = {})
      @trainee = trainee
      @specialisms = specialisms
      @itt_dates_form = IttDatesForm.new(trainee)

      assign_attributes({ mark_as_reviewed: trainee.progress.course_details }.merge(params))
    end

    def save
      update_trainee_attributes unless trainee_confirmed?
      trainee.progress.course_details = mark_as_reviewed
      clear_funding_information if course_subjects_changed?

      trainee.save!
    end

    def course_subject_one
      specialisms[0]
    end

    def course_subject_two
      specialisms[1]
    end

    def course_subject_three
      specialisms[2]
    end

    def course_age_range
      course&.age_range || trainee.course_age_range
    end

    def course_uuid
      uuid || trainee.course_uuid
    end

    def itt_start_date
      itt_dates_form.start_date || course&.start_date || trainee.itt_start_date
    end

    def itt_end_date
      itt_dates_form.end_date || course&.end_date || trainee.itt_end_date
    end

    def study_mode
      return if requires_study_mode?

      course&.study_mode || trainee.study_mode
    end

    def course_education_phase
      @course_education_phase ||= ::CourseEducationPhaseForm.new(trainee).course_education_phase
    end

  private

    attr_accessor :itt_dates_form

    def update_trainee_attributes
      trainee.assign_attributes({
        course_subject_one: course_subject_one,
        course_subject_two: course_subject_two,
        course_subject_three: course_subject_three,
        training_route: course&.route,
        course_uuid: course_uuid,
        course_age_range: course_age_range,
        itt_start_date: itt_start_date,
        itt_end_date: itt_end_date,
        study_mode: study_mode,
      })
    end

    def course
      @course ||= trainee.available_courses.find_by(uuid: uuid)
    end

    def trainee_confirmed?
      uuid == trainee.course_uuid && values_provided?
    end

    def values_provided?
      [
        trainee.course_age_range,
        trainee.itt_start_date,
        trainee.itt_end_date,
        trainee.study_mode,
      ].all?(&:present?)
    end

    def requires_study_mode?
      return false unless trainee.requires_study_mode?
      return false unless course

      course.study_mode == COURSE_STUDY_MODES[:full_time_or_part_time]
    end
  end
end
