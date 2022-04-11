class CreatePaymentProfileRow < ActiveRecord::Migration[6.1]
  def change
    create_table :payment_profile_rows do |t|
      t.integer :payment_profile_id
      t.string :description
      t.timestamps
    end

    add_index :payment_profile_rows, :payment_profile_id
  end
end
