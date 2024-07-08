# frozen_string_literal: true

class RemoveErrorousPlacementIndex < ActiveRecord::Migration[7.1]
  def up
    remove_index(:placements, column: %i[trainee_id urn]) if index_exists?(:placements, %i[trainee_id urn])
  end

  def down
    # NOTE: No point in going back
  end
end
