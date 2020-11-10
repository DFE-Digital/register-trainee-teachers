class RemoveCountyFromTrainees < ActiveRecord::Migration[6.0]
  def change
    remove_column :trainees, :county, :text
  end
end
