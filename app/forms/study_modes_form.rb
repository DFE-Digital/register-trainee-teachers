# frozen_string_literal: true

class StudyModesForm < TraineeForm
  FIELDS = %i[
    study_mode
  ].freeze

  attr_accessor(*FIELDS)

  validates :study_mode, inclusion: { in: TRAINEE_STUDY_MODE_ENUMS.keys }, if: :requires_study_mode?

private

  def compute_fields
    trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
  end

  def requires_study_mode?
    trainee.requires_study_mode?
  end
end
