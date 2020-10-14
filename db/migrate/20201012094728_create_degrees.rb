class CreateDegrees < ActiveRecord::Migration[6.0]
  def change
    create_table :degrees do |t|
      t.integer :locale_code, null: false
      t.string :uk_degree
      t.string :non_uk_degree
      t.references :trainee, null: false, foreign_key: true

      t.timestamps
    end
  end
end
