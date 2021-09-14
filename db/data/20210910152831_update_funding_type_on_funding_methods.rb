# frozen_string_literal: true

class UpdateFundingTypeOnFundingMethods < ActiveRecord::Migration[6.1]
  def up
    FundingMethod.update_all(funding_type: :bursary)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
