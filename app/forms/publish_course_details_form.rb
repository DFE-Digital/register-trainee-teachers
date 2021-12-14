# frozen_string_literal: true

class PublishCourseDetailsForm < TraineeForm
  include CourseFormHelpers

  NOT_LISTED = "not_listed"

  FIELDS = %i[
    course_uuid
  ].freeze

  attr_accessor(*FIELDS)

  validates :course_uuid, presence: true

  delegate :age_range, to: :course, prefix: true

  delegate :course_subject_one, :course_subject_two, :course_subject_three, to: :specialism_form

  def manual_entry_chosen?
    course_uuid == NOT_LISTED
  end

  def process_manual_entry!
    if trainee.draft?
      trainee.update!(
        course_uuid: nil,
        course_subject_one: nil,
        course_subject_two: nil,
        course_subject_three: nil,
        course_age_range: nil,
        itt_start_date: nil,
        itt_end_date: nil,
        study_mode: nil,
        course_education_phase: nil,
      )
    else
      CourseDetailsForm.new(trainee).nullify_and_stash!
      CourseEducationPhaseForm.new(trainee).nullify_and_stash!
    end
  end

  def save!
    return true if manual_entry_chosen?
    return false unless valid?

    update_trainee_attributes
    clear_funding_information if course_subjects_changed?
    trainee.save!
    clear_all_stashes
  end

  def stash
    return true if manual_entry_chosen?

    clear_all_stashes

    super
  end

  def language_specialism?
    specialism_type == :language
  end

  def selected_specialisms
    language_specialism? ? specialism_form.languages : specialism_form.specialisms
  end

  def course_education_phase
    @course_education_phase ||= ::CourseEducationPhaseForm.new(trainee).course_education_phase
  end

  def study_mode
    @study_mode ||= ::StudyModesForm.new(trainee).study_mode
  end

  def itt_start_date
    if trainee.requires_itt_start_date?
      itt_dates_form.start_date
    end || course.start_date
  end

  def itt_end_date
    if trainee.requires_itt_start_date?
      itt_dates_form.end_date
    end || course.end_date
  end

private

  def update_trainee_attributes
    trainee.assign_attributes(course_uuid: course_uuid,
                              course_subject_one: course_subject_one,
                              course_subject_two: course_subject_two,
                              course_subject_three: course_subject_three,
                              course_education_phase: course&.level,
                              course_age_range: course_age_range)
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

  def itt_dates_form
    @itt_dates_form ||= IttDatesForm.new(trainee)
  end

  def course
    @course ||= trainee.available_courses&.find_by(uuid: course_uuid)
  end

  def compute_fields
    trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
  end

  def clear_all_stashes
    [
      LanguageSpecialismsForm,
      SubjectSpecialismForm,
      StudyModesForm,
      IttDatesForm,
      CourseDetailsForm,
    ].each do |klass|
      klass.new(trainee).clear_stash
    end

    clear_stash
  end
end
