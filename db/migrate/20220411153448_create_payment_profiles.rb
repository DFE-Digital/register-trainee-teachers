class CreatePaymentProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :payment_profiles do |t|
      t.integer :payable_id
      t.string :payable_type
      t.timestamps
    end
  end
end
