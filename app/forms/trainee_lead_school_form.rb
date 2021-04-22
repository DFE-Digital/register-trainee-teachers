# frozen_string_literal: true

class TraineeLeadSchoolForm < TraineeForm
  attr_accessor :lead_school_id

  validates :lead_school_id, presence: true

private

  def compute_fields
    trainee.attributes.symbolize_keys.slice(:lead_school_id).merge(new_attributes)
  end
end
