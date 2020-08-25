class CreateTrainees < ActiveRecord::Migration[6.0]
  def change
    create_table :trainees do |t|
      t.text :trainee_id
      t.text :first_names
      t.text :last_name
      t.text :gender
      t.date :date_of_birth
      t.text :nationality
      t.text :ethnicity
      t.text :disability

      t.timestamps
    end
  end
end
