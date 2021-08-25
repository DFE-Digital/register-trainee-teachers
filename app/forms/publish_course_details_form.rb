# frozen_string_literal: true

class PublishCourseDetailsForm < TraineeForm
  include CourseFormHelpers

  NOT_LISTED = "not_listed"

  FIELDS = %i[
    course_code
    specialism_form
  ].freeze

  attr_accessor(*FIELDS)

  validates :course_code, presence: true

  def manual_entry_chosen?
    course_code == NOT_LISTED
  end

  def save!
    if valid?
      update_trainee_attributes
      clear_bursary_information if course_subjects_changed?
      trainee.save!
      clear_stash
    else
      false
    end
  end

private

  def specialisms
    @specialisms ||=
      case specialism_form&.to_sym
      when :language
        LanguageSpecialismsForm.new(trainee).languages
      when :general
        SubjectSpecialismForm.new(trainee).specialisms
      else
        CalculateSubjectSpecialisms.call(subjects: course.subjects.pluck(:name)).values.map(&:first).compact
      end
  end

  def study_mode
    return unless trainee.requires_study_mode?

    if TRAINEE_STUDY_MODE_ENUMS.keys.include?(course.study_mode)
      course.study_mode
    end
  end

  def update_trainee_attributes
    return if manual_entry_chosen?

    specialism1, specialism2, specialism3 = *specialisms

    trainee.assign_attributes({
      course_subject_one: specialism1,
      course_subject_two: specialism2,
      course_subject_three: specialism3,
      course_code: course.code,
      course_age_range: course.age_range,
      course_start_date: course.start_date,
      study_mode: study_mode,
      course_end_date: course.end_date,
    })
  end

  def course
    @course ||= Course.find_by(code: course_code)
  end

  def compute_fields
    new_attributes
  end
end
