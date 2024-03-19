class AddExtraAttributesForApi < ActiveRecord::Migration[7.1]
  def change
    create_table :hesa_trainee_details do |t|
      t.references :trainee, foreign_key: true, null: false

      t.string :previous_last_name
      t.string :itt_aim
      t.string :course_study_mode
      t.integer :course_year
      t.string :course_age_range
      t.date :postgrad_apprenticeship_start_date
      t.string :funding_method
      t.string :ni_number
      t.string :hesa_disabilities, array: true, default: []
      t.string :additional_training_initiative

      t.timestamps
    end
  end
end
