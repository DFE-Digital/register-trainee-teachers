# frozen_string_literal: true

class PublishCourseDetailsForm < TraineeForm
  include CourseFormHelpers

  NOT_LISTED = "not_listed"

  FIELDS = %i[
    course_uuid
  ].freeze

  attr_accessor(*FIELDS)

  validates :course_uuid, presence: true

  validates :course_end_date, presence: true, unless: :skip_course_end_date_validation?

  delegate :age_range, to: :course, prefix: true

  delegate :course_subject_one, :course_subject_two, :course_subject_three, to: :specialism_form

  def manual_entry_chosen?
    course_uuid == NOT_LISTED
  end

  def process_manual_entry!
    if trainee.draft?
      trainee.update!(
        course_code: nil,
        course_uuid: nil,
        course_subject_one: nil,
        course_subject_two: nil,
        course_subject_three: nil,
        course_age_range: nil,
        course_start_date: nil,
        course_end_date: nil,
        study_mode: nil,
      )
    else
      CourseDetailsForm.new(trainee).nullify_and_stash!
    end
  end

  def save!
    return true if manual_entry_chosen?
    return false unless valid?

    update_trainee_attributes
    clear_funding_information if course_subjects_changed?
    trainee.save!
    clear_stash
  end

  def stash
    return true if manual_entry_chosen?

    update_stashed_attrs_to_new_course_attrs

    super
  end

  def course_start_date
    if trainee.requires_itt_start_date?
      IttStartDateForm.new(trainee).date
    end || course.start_date
  end

  def study_mode
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

  def skip_course_end_date_validation?
    course_uuid.blank? || @skip_course_end_date_validation
  end

  def skip_course_end_date_validation!
    @skip_course_end_date_validation = true
  end

  def course_end_date
    nil
  end

  def clear_stash
    [
      LanguageSpecialismsForm,
      SubjectSpecialismForm,
      IttStartDateForm,
      StudyModesForm,
      CourseDetailsForm,
    ].each do |klass|
      klass.new(trainee).clear_stash
    end

    super
  end

private

  def update_stashed_attrs_to_new_course_attrs
    return unless course

    itt_start_date_form = IttStartDateForm.new(trainee)
    itt_start_date_form.add_date_fields(course.start_date)
    itt_start_date_form.stash

    study_modes_form = StudyModesForm.new(trainee, params: { study_mode: course_study_mode_if_valid })
    study_modes_form.stash

    course_details_form = CourseDetailsForm.new(trainee)
    course_details_form.assign_attributes_and_stash({
      course_uuid: course_uuid,
      course_code: course&.code,
      course_subject_one: course_subject_one,
      course_subject_two: course_subject_two,
      course_subject_three: course_subject_three,
      start_day: course_start_date&.day,
      start_month: course_start_date&.month,
      start_year: course_start_date&.year,
      end_day: course_end_date&.day,
      end_month: course_end_date&.month,
      end_year: course_end_date&.year,

      study_mode: study_mode,
    })
    course_details_form.assign_attributes_and_stash(
      course_details_form.attrs_from_course_age_range(course_age_range),
    )
  end

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
    attributes = {
      course_uuid: course_uuid,
      course_code: course&.code,
      course_education_phase: course&.level,
      course_subject_one: course_subject_one,
      course_subject_two: course_subject_two,
      course_subject_three: course_subject_three,
      course_age_range: course_age_range,
      course_end_date: course_end_date,
      study_mode: study_mode,
    }

    unless trainee.pg_teaching_apprenticeship?
      attributes.merge!({
        course_start_date: course_start_date,
      })
    end

    trainee.assign_attributes(attributes)
  end

  def course_study_mode_if_valid
    course.study_mode if TRAINEE_STUDY_MODE_ENUMS.keys.include?(course.study_mode)
  end

  def course
    @course ||= trainee.available_courses&.find_by(uuid: course_uuid)
  end

  def compute_fields
    trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
  end
end
