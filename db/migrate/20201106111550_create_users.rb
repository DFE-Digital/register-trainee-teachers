class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.references :provider, index: true, null: false, foreign_key: { to_table: :providers }

      t.timestamps
    end

    add_index :users, :email
  end
end
