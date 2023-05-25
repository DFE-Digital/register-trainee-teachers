# frozen_string_literal: true

module BulkUpdate
  class Recommend
    include ServicePattern

    def initialize(recommendations_upload:)
      @trainees = trainees_with_changed_attributes(recommendations_upload.awardable_rows.includes(:trainee))
    end

    def call
      return if trainees.empty?

      Trainee.upsert_all(build_upsert_attributes(trainees), unique_by: :slug)

      enqueue_background_jobs!(trainees)
    end

  private

    attr_reader :trainees

    def trainees_with_changed_attributes(awardable_rows)
      awardable_rows.filter_map do |row|
        trainee = row.trainee

        next unless trainee&.trn_received?

        trainee.outcome_date = row.standards_met_at
        trainee.state = :recommended_for_award
        trainee.recommended_for_award_at = Time.zone.now

        trainee
      end
    end

    def build_upsert_attributes(trainees)
      trainees.map do |trainee|
        {
          slug: trainee.slug,
          provider_id: trainee.provider_id,
          outcome_date: trainee.outcome_date,
          state: :recommended_for_award,
          recommended_for_award_at: Time.zone.now,
        }
      end
    end

    def enqueue_background_jobs!(trainees)
      trainees.each do |trainee|
        Auditing::TraineeAuditorJob.perform_later(trainee,
                                                  trainee.send(:audited_changes),
                                                  Audited.store[:current_user]&.call,
                                                  Audited.store[:current_remote_address])
        Dqt::RecommendForAwardJob.perform_later(trainee)
      end
    end
  end
end
