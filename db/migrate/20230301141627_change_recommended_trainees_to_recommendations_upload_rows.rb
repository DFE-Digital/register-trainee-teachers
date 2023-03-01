class ChangeRecommendedTraineesToRecommendationsUploadRows < ActiveRecord::Migration[7.0]
  def up
    drop_table :bulk_update_recommended_trainees

    create_table :bulk_update_recommendations_upload_rows do |t|
      t.timestamps
      t.belongs_to :bulk_update_recommendations_upload,
                   null: false,
                   foreign_key: true,
                   index: { name: :idx_bu_ru_rows_on_bu_recommendations_upload_id }
      t.integer :csv_row_number
      t.string :trn
      t.string :hesa_id
      t.date :standards_met_at
    end
  end

  def down
    drop_table :bulk_update_recommendations_upload_rows

    create_table :bulk_update_recommended_trainees do |t|
      t.timestamps
      t.belongs_to :bulk_update_recommendations_upload,
                   null: false,
                   foreign_key: true,
                   index: { name: :idx_bu_recommended_trainees_on_bu_recommendations_upload_id }
      t.integer :csv_row_number
      t.string :trn
      t.string :hesa_id
      t.date :standards_met_at
    end
  end
end
