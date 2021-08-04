# frozen_string_literal: true

class StudyModesForm < TraineeForm
  attr_accessor :study_mode

  validates :study_mode, inclusion: { in: TRAINEE_STUDY_MODES.keys }, if: :requires_study_mode?

private

  def compute_fields
    trainee.attributes.symbolize_keys.slice(:study_mode).merge(new_attributes)
  end

  def requires_study_mode?
    trainee.requires_study_mode?
  end
end
