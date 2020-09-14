class AddDttpIdToTrainees < ActiveRecord::Migration[6.0]
  def change
    # TODO: make this null: false
    add_column :trainees, :dttp_id, :uuid
    add_index :trainees, :dttp_id
  end
end
