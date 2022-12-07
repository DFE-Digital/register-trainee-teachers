# frozen_string_literal: true

class FixTraineeStates < ActiveRecord::Migration[6.1]
  def up
    %w[0263134/2/03 1317509/2/03 1505948/2/03 2010427/1/03 2035745/1/03].each do |trainee_id|
      Trainee.find_by(trainee_id:)&.update_columns(state: :trn_received)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
