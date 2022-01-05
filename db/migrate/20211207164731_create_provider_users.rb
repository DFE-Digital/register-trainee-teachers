class CreateProviderUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :provider_users do |t|
      t.integer :provider_id, index: true, foreign_key: true
      t.integer :user_id, index: true, foreign_key: true
      t.timestamps
    end
  end
end
