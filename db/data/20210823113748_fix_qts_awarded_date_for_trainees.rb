# frozen_string_literal: true

class FixQtsAwardedDateForTrainees < ActiveRecord::Migration[6.1]
  def up
    Trainee.awarded.each do |trainee|
      awarded_at = Dttp::RetrieveAward.call(trainee: trainee)["dfe_qtseytsawarddate"]
      trainee.update!(awarded_at: awarded_at)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
