# frozen_string_literal: true

class SendWithdrawnHesaTraineesToDqt < ActiveRecord::Migration[7.0]
  def up
    trainees.find_in_batches(batch_size: 100).with_index do |group, batch|
      group.each do |trainee|
        Dqt::WithdrawTraineeJob.set(wait: 30.seconds * batch).perform_later(trainee)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

private

  def trainees
    Trainee.withdrawn.where.not(hesa_id: nil)
  end
end
