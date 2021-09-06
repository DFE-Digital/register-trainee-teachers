# frozen_string_literal: true

class PublishCourseDetailsForm < TraineeForm
  include CourseFormHelpers

  NOT_LISTED = "not_listed"

  FIELDS = %i[
    course_code
  ].freeze

  attr_accessor(*FIELDS)

  validates :course_code, presence: true

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
    else
      clear_stash
      clear_form_stashes
    end
  end

  def save!
    clear_form_stashes
    return true if manual_entry_chosen?

    if valid?
      reset_course_subject_fields
      update_trainee_attributes
      clear_bursary_information if course_subjects_changed?
      trainee.save!
      clear_stash
    else
      false
    end
  end

  def stash
    clear_form_stashes
    return true if manual_entry_chosen?

    reset_course_subject_fields
    super
  end

  delegate :course_subject_one, :course_subject_two, :course_subject_three,
           to: :specialism_form

  delegate :age_range, to: :course, prefix: true

  def course_start_date
    @course_start_date ||=
      if trainee.requires_itt_start_date?
        IttStartDateForm.new(trainee).date
      end || course.start_date
  end

  delegate :end_date, to: :course, prefix: true

  def study_mode
    @study_mode ||=
      if trainee.requires_study_mode?
        StudyModesForm.new(trainee).study_mode
      end || course_study_mode_if_valid
  end

  def course_has_one_specialism?
    CalculateSubjectSpecialisms.call(subjects: course_subjects).all? { |_, v| v.count < 2 }
  end

  def language_specialism?
    specialism_type == :language
  end

  def general_specialism?
    specialism_type == :general
  end

private

  def course_subjects
    @course_subjects ||= course.subjects.map(&:name)
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

  def clear_form_stashes
    FormStore.set(trainee.id, :subject_specialism, nil)
    FormStore.set(trainee.id, :language_specialisms, nil)
    FormStore.set(trainee.id, :itt_start_date, nil)
  end

  def reset_course_subject_fields
    return unless course

    subjects = {
      course_subject_one: nil,
      course_subject_two: nil,
      course_subject_three: nil,
    }

    if course_has_one_specialism?
      subjects[:course_subject_one] = CalculateSubjectSpecialisms.call(
        subjects: course.subjects.pluck(:name),
      ).values.map(&:first).compact.first
    end

    specialism_form.fields.merge!(subjects)
    specialism_form.stash_or_save!
    @specialism_form = nil #  reload
  end

  def update_trainee_attributes
    trainee.assign_attributes({
      course_code: course_code,
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
end
