# frozen_string_literal: true

class PublishCourseDetailsForm < TraineeForm
  NOT_LISTED = "not_listed"

  FIELDS = %i[
    code
  ].freeze

  attr_accessor(*FIELDS)

  validates :code, presence: true

  def manual_entry_chosen?
    code == NOT_LISTED
  end

private

  def compute_fields
    new_attributes
  end
end
