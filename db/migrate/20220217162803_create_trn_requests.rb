class CreateTrnRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :trn_requests do |t|
      t.references :trainee, null: false, foreign_key: true
      t.uuid :request_id
      t.integer :state
      t.timestamps
    end

    add_index :trn_requests, :request_id
    add_index :trn_requests, :state
  end
end
