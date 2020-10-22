class AddIndexToRecordType < ActiveRecord::Migration[6.0]
  def change
    add_index :trainees, :record_type
  end
end
