class RemoveUrnUniqueContraintFromPlacements < ActiveRecord::Migration[7.2]
  def change
    remove_index :placements, %i[trainee_id urn]
  end
end
