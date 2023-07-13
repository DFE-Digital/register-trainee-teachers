# frozen_string_literal: true

class FixDqtDuplicateRecord5682 < ActiveRecord::Migration[7.0]
  def up
    Trainee.find_by(trn: 2181121)&.update!(trn: 2242316, audit_comment: "DQT duplicate record TRN needed correcting")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
