class CreatePaymentProfileRowAmounts < ActiveRecord::Migration[6.1]
  def change
    create_table :payment_profile_row_amounts do |t|
      t.integer :payment_profile_row_id
      t.integer :month
      t.integer :year
      t.integer :amount_in_pence
      t.boolean :predicted
      t.timestamps
    end

    add_index :payment_profile_row_amounts, :payment_profile_row_id
  end
end
