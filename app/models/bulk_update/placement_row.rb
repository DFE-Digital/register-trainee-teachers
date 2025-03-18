# frozen_string_literal: true

# == Schema Information
#
# Table name: bulk_update_placement_rows
#
#  id                       :bigint           not null, primary key
#  csv_row_number           :integer          not null
#  state                    :integer          default("pending"), not null
#  trn                      :string           not null
#  urn                      :string           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  bulk_update_placement_id :bigint           not null
#  school_id                :bigint
#
# Indexes
#
#  index_bulk_update_placement_rows_on_bulk_update_placement_id  (bulk_update_placement_id)
#  index_bulk_update_placement_rows_on_school_id                 (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (bulk_update_placement_id => bulk_update_placements.id)
#  fk_rails_...  (school_id => schools.id)
#
class BulkUpdate::PlacementRow < ApplicationRecord
  belongs_to :bulk_update_placement,
             class_name: "BulkUpdate::Placement"

  belongs_to :school, optional: true

  has_many :row_errors, as: :errored_on, class_name: "BulkUpdate::RowError"

  enum :state, {
    pending: 0,
    importing: 1,
    imported: 2,
    failed: 3,
  }

  def can_be_imported?
    pending? || failed?
  end

  def row_error_messages
    row_errors.map(&:message).join("\n")
  end
end
