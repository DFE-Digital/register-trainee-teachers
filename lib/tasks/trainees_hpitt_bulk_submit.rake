# frozen_string_literal: true

namespace :trainees do
  desc "submits all of the HPITT records for TRN"
  task hpitt_bulk_submit: :environment do
    provider = Provider.find_by!(code: "HPITT")

    current_interval = 0
    interval_increment = 15
    batch_size = 10

    provider.trainees.draft.find_in_batches(batch_size: batch_size) do |trainee_group|
      trainee_group.each do |trainee|
        next unless Submissions::TrnValidator.new(trainee: trainee).valid?

        trainee.submit_for_trn!
        Dqt::RegisterForTrnJob.set(wait: current_interval.seconds).perform_later(trainee)
      end
      current_interval += interval_increment
    end
  end
end
