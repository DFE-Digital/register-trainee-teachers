# frozen_string_literal: true

class FixUpDisabilityDisclosures < ActiveRecord::Migration[6.1]
  def up
    Trainee
      .where(diversity_disclosure: Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed])
      .update_all(disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided])
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
