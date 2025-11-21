# frozen_string_literal: true

class StudyModesForm < TraineeForm
  FIELDS = %i[
    study_mode
  ].freeze

  attr_accessor(*FIELDS)

  validates :study_mode, inclusion: { in: ReferenceData::TRAINEE_STUDY_MODES.names }, if: :requires_study_mode?

  def stash
    form = CourseDetailsForm.new(trainee)
    form.assign_attributes_and_stash({
      study_mode:,
    })
    super
  end

private

  def compute_fields
    trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
  end

  def requires_study_mode?
    trainee.requires_study_mode?
  end
end
