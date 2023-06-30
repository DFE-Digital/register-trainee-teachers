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
  delegate :training_route, to: :training_routes_form
  delegate :course_subject_one, :course_subject_two, :course_subject_three, to: :specialism_form

  def initialize(...)
    super(...)
    @training_routes_form = TrainingRoutesForm.new(trainee)
  end

  def manual_entry_chosen?
    course_uuid == NOT_LISTED
  end

  def process_manual_entry!
    if trainee.draft?
      Trainees::Update.call(
        trainee: trainee,
        params: {
          course_uuid: nil,
          course_subject_one: nil,
          course_subject_two: nil,
          course_subject_three: nil,
          course_age_range: nil,
          itt_start_date: nil,
          itt_end_date: nil,
          study_mode: nil,
          course_education_phase: nil,
          course_allocation_subject: nil,
        },
      )
    else
      CourseDetailsForm.new(trainee).nullify_and_stash!
      CourseEducationPhaseForm.new(trainee).nullify_and_stash!
    end
  end

  def save!
    if manual_entry_chosen?
      store.set(id, form_store_key, { course_uuid: NOT_LISTED })
      return true
    end

    return false unless valid?

    update_trainee_attributes
    clear_funding_information if clear_funding_information?
    Trainees::Update.call(trainee:)
    clear_all_course_related_stashes
  end

  def stash
    clear_all_course_related_stashes

    super
  end

  def language_specialism?
    specialism_type == :language || specialism_type == :language_and_other
  end

  def selected_specialisms
    language_specialism? ? specialism_form.languages : specialism_form.specialisms
  end

  def course_education_phase
    @course_education_phase = course&.level || CourseEducationPhaseForm.new(trainee).course_education_phase
  end

  def study_mode
    @study_mode = StudyModesForm.new(trainee).study_mode
  end

  def itt_start_date
    itt_dates_form.start_date || course.start_date
  end

  def itt_end_date
    itt_dates_form.end_date || course.end_date
  end

private

  attr_reader :training_routes_form

  def update_trainee_attributes
    trainee.assign_attributes(training_route: training_routes_form.training_route,
                              course_uuid: course_uuid,
                              course_subject_one: course_subject_one,
                              course_subject_two: course_subject_two,
                              course_subject_three: course_subject_three,
                              course_education_phase: course_education_phase,
                              course_age_range: course_age_range,
                              course_allocation_subject: course_allocation_subject,
                              itt_start_date: itt_start_date,
                              itt_end_date: itt_end_date,
                              study_mode: study_mode)
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
    @course ||= trainee.available_courses(training_routes_form.training_route)&.find_by(uuid: course_uuid)
  end

  def compute_fields
    trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
  end
end
