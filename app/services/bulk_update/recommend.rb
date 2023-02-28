# frozen_string_literal: true

module BulkUpdate
  class Recommend
    include ServicePattern

    def initialize(recommendations_upload:)
      @awardable_rows = recommendations_upload.awardable_rows
    end

    def call
      return if awardable_rows.empty?

      awardable_rows.find_each do |row|
        # trainee = row.trainee

        # TODO: this will actually be an association on the row
        trainee = Trainee.find_by(trn: row.trn)
        next if trainee.nil?

        trainee.outcome_date = row.standards_met_at

        if trainee.save!
          trainee.recommend_for_award!

          if FeatureService.enabled?(:integrate_with_dqt)
            Dqt::RecommendForAwardJob.perform_later(trainee)
          end
        end
      end
    end

  private

    attr_reader :awardable_rows
  end
end
