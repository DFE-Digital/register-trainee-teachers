# frozen_string_literal: true

class UpdateBursaryTiersEnumValues < ActiveRecord::Migration[6.1]
  def change
    # This is a legacy migration that was used as a data migration. It does not need to be run again.
    # Commented out here as it causes issues when creating a new environment.
    # Trainee.where(bursary_tier: 2).update_all(bursary_tier: 3)
    # Trainee.where(bursary_tier: 1).update_all(bursary_tier: 2)
    # Trainee.where(bursary_tier: 0).update_all(bursary_tier: 1)
  end
end
