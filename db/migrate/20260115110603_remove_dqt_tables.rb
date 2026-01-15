# frozen_string_literal: true

class RemoveDqtTables < ActiveRecord::Migration[7.2]
  def change
    drop_table :dqt_teacher_trainings do |t|
      t.bigint :dqt_teacher_id
      t.string :programme_start_date
      t.string :programme_end_date
      t.string :programme_type
      t.string :result
      t.string :provider_ukprn
      t.string :hesa_id
      t.boolean :active
      t.timestamps

      t.index [:dqt_teacher_id], name: "index_dqt_teacher_trainings_on_dqt_teacher_id"
    end

    drop_table :dqt_teachers do |t|
      t.string :trn
      t.string :first_name
      t.string :last_name
      t.string :date_of_birth
      t.string :qts_date
      t.string :eyts_date
      t.string :early_years_status_name
      t.string :early_years_status_value
      t.string :hesa_id
      t.boolean :allowed_pii_updates, default: false, null: false
      t.timestamps

      t.index [:allowed_pii_updates], name: "index_dqt_teachers_on_allowed_pii_updates"
    end
  end
end
