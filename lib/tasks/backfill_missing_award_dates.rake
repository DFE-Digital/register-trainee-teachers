# frozen_string_literal: true

namespace :dqt do
  desc "Backfill missing trainee award dates"
  task backfill_missing_award_dates: :environment do
    failed_trainee_ids = []
    Trainee.awarded.where(awarded_at: nil).where.not(trn: nil).each do |trainee|
      response = Dqt::RetrieveTeacher.call(trainee: trainee)
      awarded_at = response.dig("qualified_teacher_status", "qts_date")
      Trainees::Update.call(trainee: trainee, params: { awarded_at: awarded_at }, update_dtq: false) if awarded_at
    rescue Dqt::Client::HttpError
      failed_trainee_ids << trainee.id
    ensure
      sleep(0.1) # DQT API has a limit of 300/rpm
    end
    puts failed_trainee_ids
  end
end
