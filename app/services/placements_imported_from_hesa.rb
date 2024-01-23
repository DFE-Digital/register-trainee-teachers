# frozen_string_literal: true

class PlacementsImportedFromHesa
  include ServicePattern

  NEW_PLACEMENTS_RELEASE_DATE = Date.new(2023, 12, 13).freeze

  def initialize(trainee:)
    @trainee = trainee
  end

  def call
    return false if @trainee.placements.blank?

    @trainee.hesa_record? &&
      @trainee.placements.all? { |placement| created_by_hesa?(placement) }
  end

private

  def created_by_hesa?(placement)
    placement.audits.exists?(action: "create", username: "HESA")
  end
end
