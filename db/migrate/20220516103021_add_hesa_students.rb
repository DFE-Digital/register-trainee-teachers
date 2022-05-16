# frozen_string_literal: true

class AddHesaStudents < ActiveRecord::Migration[6.1]
  def change
    create_table :hesa_students do |t|
      t.bigint :hesa_id
      t.string :first_names
      t.string :last_name
      t.string :email
      t.string :date_of_birth
      t.string :ethnic_background
      t.string :gender
      t.string :ukprn
      t.string :trainee_id
      t.string :course_subject_one
      t.string :course_subject_two
      t.string :course_subject_three
      t.string :itt_start_date
      t.string :itt_end_date
      t.string :employing_school_urn
      t.string :lead_school_urn
      t.string :mode
      t.string :course_age_range
      t.string :commencement_date
      t.string :training_initiative
      t.string :disability
      t.string :end_date
      t.string :reason_for_leaving
      t.string :bursary_level
      t.string :trn
      t.string :training_route
      t.string :nationality
      t.string :hesa_updated_at
      t.string :itt_aim
      t.string :itt_qualification_aim
      t.string :fund_code
      t.string :study_length
      t.string :study_length_unit
      t.string :service_leaver
      t.string :course_programme_title
      t.string :pg_apprenticeship_start_date
      t.string :year_of_course
      t.json :degrees
      t.json :placements
      t.timestamps
    end
  end
end
