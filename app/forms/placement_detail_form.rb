# frozen_string_literal: true

class PlacementDetailForm < TraineeForm
  FIELDS = %i[
    placement_detail
  ].freeze

  attr_accessor(*FIELDS)

  validates :placement_detail, presence: true, inclusion: { in: PLACEMENT_DETAIL_ENUMS.values }

  def detail_provided?
    placement_detail == PLACEMENT_DETAIL_ENUMS[:has_placement_detail]
  end

  def detail_not_provided?
    placement_detail == PLACEMENT_DETAIL_ENUMS[:no_placement_detail]
  end

private

  def compute_fields
    trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
  end
end
