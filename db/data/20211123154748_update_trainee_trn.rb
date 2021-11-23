# frozen_string_literal: true

class UpdateTraineeTrn < ActiveRecord::Migration[6.1]
  def up
    Trainee.find_by(trainee_id: "C123422")&.update(trn: 2073564)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
