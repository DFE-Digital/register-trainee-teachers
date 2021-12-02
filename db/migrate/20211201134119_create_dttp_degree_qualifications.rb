class CreateDttpDegreeQualifications < ActiveRecord::Migration[6.1]
  def change
    create_table :dttp_degree_qualifications do |t|
      t.jsonb :response
      t.integer :state, default: 0
      t.uuid :dttp_id, null: false
      t.uuid :contact_dttp_id
      t.timestamps default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :dttp_degree_qualifications, :dttp_id, unique: true
  end
end
