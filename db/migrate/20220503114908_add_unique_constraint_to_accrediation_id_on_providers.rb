# frozen_string_literal: true

class AddUniqueConstraintToAccrediationIdOnProviders < ActiveRecord::Migration[6.1]
  def change
    remove_index :providers, :accreditation_id
    add_index :providers, :accreditation_id, unique: true
  end
end
