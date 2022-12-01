# frozen_string_literal: true

namespace :hesa do
  task :fix_deferred_states do
    Trainee.includes(:hesa_student).deferred.where(record_source: %w[hesa_collection hesa_trn_data]).find_each do |trainee|
      Hesa::BackfillTraineeStates.call(trainee:)
    end
  end
end
