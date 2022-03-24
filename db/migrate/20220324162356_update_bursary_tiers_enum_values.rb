# frozen_string_literal: true

class UpdateBursaryTiersEnumValues < ActiveRecord::Migration[6.1]
  def change
    Trainee.where(bursary_tier: 2).update_all(bursary_tier: 3)
    Trainee.where(bursary_tier: 1).update_all(bursary_tier: 2)
    Trainee.where(bursary_tier: 0).update_all(bursary_tier: 1)
  end
end
