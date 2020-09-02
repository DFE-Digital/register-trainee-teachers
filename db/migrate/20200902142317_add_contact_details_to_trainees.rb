class AddContactDetailsToTrainees < ActiveRecord::Migration[6.0]
  def change
    change_table :trainees, bulk: true do |t|
      t.column :address_line_one, :text, null: true
      t.column :address_line_two, :text, null: true
      t.column :town_city, :text, null: true
      t.column :county, :text, null: true
      t.column :postcode, :text, null: true
      t.column :phone, :text, null: true
      t.column :email, :text, null: true
    end
  end
end
