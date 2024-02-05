class CreateAuthenticationTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :authentication_tokens do |t|
      t.string :hashed_token
      t.boolean :enabled, default: true
      t.references :provider, foreign_key: true
      t.date :expires_at

      t.timestamps
    end
  end
end
