# frozen_string_literal: true

class EmployingSchoolForm < SchoolForm
  attr_accessor :employing_school_id

  validates :employing_school_id, presence: true, unless: -> { searching_again? }

  alias_method :school_id, :employing_school_id

private

  def compute_fields
    trainee.attributes.symbolize_keys.slice(:employing_school_id).merge(new_attributes)
  end
end
