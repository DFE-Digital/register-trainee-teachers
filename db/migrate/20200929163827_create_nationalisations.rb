class CreateNationalisations < ActiveRecord::Migration[6.0]
  def change
    create_table :nationalisations do |t|
      t.references :trainee, index: true, null: false, foreign_key: { to_table: :trainees }
      t.references :nationality, index: true, null: false, foreign_key: { to_table: :nationalities }
      t.timestamps
    end
  end
end
