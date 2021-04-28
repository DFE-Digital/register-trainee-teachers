# frozen_string_literal: true

class EmployingSchoolForm < TraineeForm
  attr_accessor :employing_school_id

  validates :employing_school_id, presence: true

private

  def compute_fields
    trainee.attributes.symbolize_keys.slice(:employing_school_id).merge(new_attributes)
  end
end
