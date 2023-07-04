# frozen_string_literal: true

class SyncMoreIntrainingTraineesToDqtPriorToFeb2023 < ActiveRecord::Migration[7.0]
  def up
    in_training = Trainee.where.not(trn: nil).where("length(trn) = 7").in_training.where("updated_at <= ?", Date.new(2023, 2).end_of_month)

    in_training.find_in_batches(batch_size: 500).with_index do |group, batch|
      group.each do |trainee|
        Dqt::UpdateTraineeJob.set(wait: 30.seconds * batch).perform_later(trainee)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
