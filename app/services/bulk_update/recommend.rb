# frozen_string_literal: true

module BulkUpdate
  class Recommend
    include ServicePattern

    def initialize(recommendations_upload:)
      @recommendations_upload = recommendations_upload
    end

    def call
      return if trainees.empty?

      InsertAll.call(
        original: original,
        modified: modified,
        model: Trainee,
        unique_by: :slug
      )
    end

  private

    ATTRIBUTES = %i[id slug outcome_date state recommended_for_award_at]

    # Builds a hash of trainees, indexed by ID, who meet all criteria for an award.
    def original
      @original ||= recommendations_upload.awardable_rows.each_with_object({}) do |row, hash|
        trainee = row.trainee

        next unless trainee&.trn_received?

        hash[trainee.id] = trainee.attributes.with_indifferent_access.slice(*ATTRIBUTES)
      end
    end

    # Modifies attributes of original trainees based on user input, indexed by trainee ID.
    def modified
      @modified ||= recommendations_upload.awardable_rows(include_trainee: false).each_with_object({}) do |row, hash|
        trainee_id = row.matched_trainee_id

        next unless original.key?(trainee_id)

        hash[trainee_id] = original[trainee_id].merge(
          outcome_date: row.standards_met_at,
          state: :recommended_for_award,
          recommended_for_award: Time.zone.now
        )
      end.with_indifferent_access
    end
  end
end
