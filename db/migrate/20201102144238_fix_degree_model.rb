class FixDegreeModel < ActiveRecord::Migration[6.0]
  def change
    rename_column :degrees, :degree_grade, :grade
    rename_column :degrees, :degree_subject, :subject
  end
end
