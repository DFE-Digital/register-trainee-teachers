# frozen_string_literal: true

module ApplyApplications
  class ConfirmCourseForm
    include ActiveModel::Model
    include CourseFormHelpers

    FIELDS = %i[
      code
      mark_as_reviewed
    ].freeze

    attr_accessor(*FIELDS, :trainee, :specialisms, :itt_start_date, :params)

    delegate :id, :persisted?, to: :trainee

    def initialize(trainee, specialisms, itt_start_date, params = {})
      @trainee = trainee
      @specialisms = specialisms
      @itt_start_date = itt_start_date

      assign_attributes({ mark_as_reviewed: trainee.progress.course_details }.merge(params))
    end

    def save
      update_trainee_attributes

      clear_bursary_information if course_subjects_changed?

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

    def course_code
      code || trainee.course_code
    end

    def course_start_date
      itt_start_date || course&.start_date || trainee.course_start_date
    end

    def course_end_date
      course&.end_date || trainee.course_end_date
    end

    def study_mode
      course&.study_mode || trainee.study_mode
    end

  private

    def update_trainee_attributes
      trainee.assign_attributes({
        course_subject_one: course_subject_one,
        course_subject_two: course_subject_two,
        course_subject_three: course_subject_three,
        training_route: course&.route,
        course_code: course_code,
        course_age_range: course_age_range,
        course_start_date: course_start_date,
        course_end_date: course_end_date,
        study_mode: study_mode,
      })
      trainee.progress.course_details = mark_as_reviewed
    end

    def course
      @course ||= trainee.available_courses.find_by(code: code || trainee.course_code)
    end

    def training_route
      course&.route || trainee.training_route
    end
  end
end
