class CreateLeadSchoolUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :lead_school_users do |t|
      t.integer :user_id, index: true, foreign_key: true
      t.integer :lead_school_id, index: true, foreign_key: true
      t.timestamps
    end
  end
end
