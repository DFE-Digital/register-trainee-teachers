class AddProviderIdToTrainees < ActiveRecord::Migration[6.0]
  def change
    add_reference :trainees, :provider, foreign_key: true, null: false
  end
end
