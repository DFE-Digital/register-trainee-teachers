class AddPreviousEducation < ActiveRecord::Migration[6.0]
  def change
    change_table :trainees, bulk: true do |t|
      t.column :a_level_1_subject, :text, null: true
      t.column :a_level_1_grade, :text, null: true

      t.column :a_level_2_subject, :text, null: true
      t.column :a_level_2_grade, :text, null: true

      t.column :a_level_3_subject, :text, null: true
      t.column :a_level_3_grade, :text, null: true

      t.column :degree_subject, :text, null: true
      t.column :degree_class, :text, null: true
      t.column :degree_institution, :text, null: true
      t.column :degree_type, :text, null: true

      t.column :ske, :text, null: true
      t.column :previous_qts, :boolean, null: true
    end
  end
end
