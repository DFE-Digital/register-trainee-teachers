# frozen_string_literal: true

class CreateHesaMetadata < ActiveRecord::Migration[6.1]
  def change
    create_table :hesa_metadata do |t|
      t.belongs_to :trainee
      t.column :study_length, :integer
      t.column :study_length_unit, :string
      t.column :itt_aim, :string
      t.column :itt_qualification_aim, :string
      t.column :fundability, :string
      t.column :service_leaver, :string
      t.column :course_programme_title, :string
      t.column :placement_school_urn, :integer
      t.column :pg_apprenticeship_start_date, :date
      t.column :year_of_course, :string
      t.timestamps
    end
  end
end
