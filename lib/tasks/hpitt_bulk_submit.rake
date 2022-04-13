# frozen_string_literal: true

namespace :hpitt do
  desc "Task to submit all of the HPITT records for TRN"
  task bulk_submit: :environment do
    trainees_to_exclude = %w[0034G00002fqS22QAE]
    teach_first_provider_id = 209
    teach_first = Provider.find(teach_first_provider_id)

    current_interval = 0
    interval_increment = 15
    batch_size = 10

    teach_first.trainees.draft.find_in_batches(batch_size: batch_size) do |trainee_group|
      trainee_group.each do |trainee|
        next if trainees_to_exclude.include?(trainee.trainee_id)

        next unless Submissions::TrnValidator.new(trainee: trainee).valid?

        trainee.submit_for_trn!

        Dqt::RegisterForTrnJob.set(wait: current_interval.seconds).perform_later(trainee)
      end
      current_interval += interval_increment
    end
  end
end
