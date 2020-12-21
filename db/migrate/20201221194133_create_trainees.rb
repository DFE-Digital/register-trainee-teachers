# frozen_string_literal: true

class CreateTrainees < ActiveRecord::Migration[6.0]
  def change
    create_table :trainees, id: :uuid do |t|
      t.belongs_to :provider, type: :uuid, index: true, null: false, foreign_key: { to_table: :providers }
      t.uuid :dttp_id, index: true
      t.uuid :placement_assignment_dttp_id
      t.text :trainee_id
      t.text :first_names
      t.text :middle_names
      t.text :last_name
      t.integer :gender, index: true
      t.date :date_of_birth
      t.text :nationality
      t.text :address_line_one
      t.text :address_line_two
      t.text :town_city
      t.text :postcode
      t.text :international_address
      t.text :email
      t.integer :ethnic_group, index: true
      t.text :ethnic_background
      t.text :additional_ethnic_background
      t.text :subject
      t.text :age_range
      t.integer :record_type, index: true
      t.integer :locale_code, index: true
      t.integer :diversity_disclosure, index: true
      t.text :ethnicity
      t.text :disability
      t.integer :disability_disclosure, index: true
      t.date :outcome_date
      t.date :programme_start_date
      t.date :programme_end_date
      t.string :trn
      t.datetime :submitted_for_trn_at
      t.integer  :withdraw_reason
      t.date :withdraw_date
      t.date :defer_date
      t.string  :additional_withdraw_reason
      t.integer :state, default: 0, index: true
      t.jsonb :progress, default: {}, index: { using: :gin }
      t.timestamps
    end
  end
end
