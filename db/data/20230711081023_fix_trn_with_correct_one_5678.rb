# frozen_string_literal: true

class FixTrnWithCorrectOne5678 < ActiveRecord::Migration[7.0]
  def up
    Trainee.find_by(trn: 2041177)&.update!(trn: 2162926, audit_comment: "TRN needed correcting")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
