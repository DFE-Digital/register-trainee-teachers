class AddCourseDetailsFieldsToTrainees < ActiveRecord::Migration[6.0]
  def change
    change_table :trainees, bulk: true do |t|
      t.column :course_title, :text, null: true
      t.column :course_phase, :text, null: true
      t.column :programme_start_date, :date, null: true
      t.column :programme_length, :text, null: true
      t.column :programme_end_date, :date, null: true
      t.column :allocation_subject, :text, null: true
      t.column :itt_subject, :text, null: true
      t.column :employing_school, :text, null: true
      t.column :placement_school, :text, null: true
    end
  end
end
