# frozen_string_literal: true

class PublishCourseDetailsForm < TraineeForm
  include CourseFormHelpers

  NOT_LISTED = "not_listed"

  FIELDS = %i[
    course_code
  ].freeze

  attr_accessor(*FIELDS)

  validates :course_code, presence: true

  delegate :age_range, :end_date, to: :course, prefix: true

  delegate :course_subject_one, :course_subject_two, :course_subject_three, to: :specialism_form

  def manual_entry_chosen?
    course_code == NOT_LISTED
  end

  def process_manual_entry!
    if trainee.draft?
      trainee.update!(
        course_code: nil,
        course_subject_one: nil,
        course_subject_two: nil,
        course_subject_three: nil,
        course_age_range: nil,
        course_start_date: nil,
        course_end_date: nil,
        study_mode: nil,
      )
    end
  end

  def save!
    return true if manual_entry_chosen?
    return false unless valid?

    update_trainee_attributes
    clear_bursary_information if course_subjects_changed?
    trainee.save!
    clear_stash
  end

  def stash
    return true if manual_entry_chosen?

    super
  end

  def course_start_date
    return course.start_date if different_course_chosen?

    if trainee.requires_itt_start_date?
      IttStartDateForm.new(trainee).date
    end || course.start_date
  end

  def study_mode
    return course_study_mode_if_valid if different_course_chosen?

    if trainee.requires_study_mode?
      StudyModesForm.new(trainee).study_mode
    end || course_study_mode_if_valid
  end

  def language_specialism?
    specialism_type == :language
  end

  def selected_specialisms
    language_specialism? ? specialism_form.languages : specialism_form.specialisms
  end

private

  def course_subjects
    @course_subjects ||= course.subjects.pluck(:name)
  end

  def specialism_type
    @specialism_type ||= CalculateSubjectSpecialismType.call(subjects: course_subjects)
  end

  def specialism_form
    @specialism_form ||=
      if language_specialism?
        LanguageSpecialismsForm.new(trainee)
      else
        SubjectSpecialismForm.new(trainee)
      end
  end

  def update_trainee_attributes
    trainee.assign_attributes({
      course_code: course_code,
      course_education_phase: course&.level,
      course_subject_one: course_subject_one,
      course_subject_two: course_subject_two,
      course_subject_three: course_subject_three,
      course_age_range: course_age_range,
      course_start_date: course_start_date,
      course_end_date: course_end_date,
      study_mode: study_mode,
    })
  end

  def course_study_mode_if_valid
    course.study_mode if TRAINEE_STUDY_MODE_ENUMS.keys.include?(course.study_mode)
  end

  def course
    @course ||= trainee.available_courses&.find_by(code: course_code)
  end

  def compute_fields
    trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
  end

  def different_course_chosen?
    course_code != trainee.course_code
  end
end
