# frozen_string_literal: true

# == Schema Information
#
# Table name: bulk_update_placement_rows
#
#  id                       :bigint           not null, primary key
#  csv_row_number           :integer          not null
#  state                    :integer          default(0), not null
#  trn                      :string           not null
#  urn                      :string           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  bulk_update_placement_id :bigint           not null
#  school_id                :bigint
#
# Indexes
#
#  idx_uniq_placement_rows                                       (bulk_update_placement_id,csv_row_number,trn,urn) UNIQUE
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
             class_name: "BulkUpdate::Placement",
             inverse_of: :bulk_update_placement_rows

  belongs_to :school

  has_many :row_errors, as: :errored_on, class_name: "BulkUpdate::RowError"

  enum state: {
    new: 0,
    imported: 1,
    failed: 2,
  }
end
