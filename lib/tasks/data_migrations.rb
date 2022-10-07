# frozen_string_literal: true

namespace :data_migrations do
  desc "backfill hesa_trn_submissions for trainees"
  task backfill_hesa_trn_submissions: :environment do
    DataMigrations::BackFillHesaTrnSubmissions.call
  end
end
