class AddRecordTypeToTrainees < ActiveRecord::Migration[6.0]
  def change
    add_column :trainees, :record_type, :integer
    add_index :trainees, :record_type
  end
end
