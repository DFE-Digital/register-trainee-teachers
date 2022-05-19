# frozen_string_literal: true

class FetchTrnsFromHesaRecords < ActiveRecord::Migration[6.1]
  def up
    trainees = Trainee.joins(:hesa_student).where(trainees: { trn: nil }).where.not(hesa_students: { trn: nil })
    trainees.each do |t|
      t.update(trn: t.hesa_student.trn)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
