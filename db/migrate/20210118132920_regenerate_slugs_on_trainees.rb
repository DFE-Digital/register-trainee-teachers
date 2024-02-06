# frozen_string_literal: true

class RegenerateSlugsOnTrainees < ActiveRecord::Migration[6.1]
  def up
    # This is a legacy migration that was used as a data migration. It does not need to be run again.
    # Commented out here as it causes issues when creating a new environment.
    # Trainee.find_each(&:regenerate_slug)
  end

  def down
    Trainee.update_all(slug: nil)
  end
end
