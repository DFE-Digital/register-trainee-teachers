# frozen_string_literal: true

class LeadSchoolForm < SchoolForm
  attr_accessor :lead_school_id

  validates :lead_school_id, presence: true, unless: -> { searching_again? }

  alias_method :school_id, :lead_school_id

private

  def compute_fields
    trainee.attributes.symbolize_keys.slice(:lead_school_id).merge(new_attributes)
  end
end
