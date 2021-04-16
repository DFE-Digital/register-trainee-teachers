class CreateCoursesSpikes < ActiveRecord::Migration[6.1]
  def change
    create_table :courses_spikes do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :accredited_body_code, null: false
      t.date :start_date, null: false
      t.string :level, null: false
      t.integer :age_range, null: false
      t.integer :duration_in_years, null: false
      t.string :course_length, null: false
      t.integer :qualification, null: false
      t.timestamps
    end
  end
end
