# frozen_string_literal: true

class RemoveUniqueIndexInBulkUpdatePlacementRows < ActiveRecord::Migration[7.2]
  def change
    remove_index :bulk_update_placement_rows,
                 %i[bulk_update_placement_id csv_row_number trn urn],
                 name: :idx_uniq_placement_rows, unique: true
  end
end
