# frozen_string_literal: true

class RemoveDuplicateTrainees < ActiveRecord::Migration[6.1]
  def up
    # These records no longer exist in DTTP
    Trainee.where(slug: %w[7juoh4yB9PzoHj6vurwX9MHe wcMqhXzPC9bmfcVx9f8tHFKB]).each(&:destroy)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
