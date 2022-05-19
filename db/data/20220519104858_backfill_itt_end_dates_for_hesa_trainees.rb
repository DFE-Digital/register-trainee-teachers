# frozen_string_literal: true

class BackfillIttEndDatesForHesaTrainees < ActiveRecord::Migration[6.1]
  def up
    trainees = Trainee.joins(:hesa_student)
                      .where(itt_end_date: nil)
                      .where.not({ hesa_student: { itt_end_date: nil } })

    trainees.find_each do |trainee|
      trainee.without_auditing do
        trainee.update(itt_end_date: trainee.hesa_student.itt_end_date)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
