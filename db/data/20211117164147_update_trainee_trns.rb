# frozen_string_literal: true

class UpdateTraineeTrns < ActiveRecord::Migration[6.1]
  def up
    [
      { trainee_id: "C123414", trn: 2073539 },
      { trainee_id: "C7947", trn: 2073497 },
      { trainee_id: "C123420", trn: 2073540 },
      { trainee_id: "1443603", trn: 2073562 },
    ].each do |attrs|
      trainee = Trainee.find_by(trainee_id: attrs[:trainee_id])
      trainee&.update(trn: attrs[:trn])
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
