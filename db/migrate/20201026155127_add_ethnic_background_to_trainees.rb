class AddEthnicBackgroundToTrainees < ActiveRecord::Migration[6.0]
  def change
    change_table :trainees, bulk: true do |t|
      t.column :ethnic_background, :text, null: true
      t.column :additional_ethnic_background, :text, null: true
    end
  end
end
