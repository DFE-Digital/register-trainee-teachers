# frozen_string_literal: true

module BulkUpdate
  class Recommend
    include ServicePattern

    # We include provider_id as part of the attributes even though it won't change.
    # This is because `upsert_all` requires all NOT NULL fields to be present for a successful upsert operation
    # (this is because it may have to INSERT, even though in this case it will always be an UPDATE - it doesn't know this)
    ATTRIBUTES = %i[slug outcome_date state recommended_for_award_at provider_id].freeze

    def initialize(recommendations_upload:)
      @recommendations_upload = recommendations_upload
    end

    def call
      return if original&.keys&.empty?

      result = UpsertAll.call(
        original: original,
        modified: modified,
        model: Trainee,
        unique_by: :slug,
      )

      send_updates if result.present?
    end

  private

    attr_reader :recommendations_upload

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
          recommended_for_award_at: Time.zone.now,
        )
      end.with_indifferent_access
    end

    def send_updates
      trainees.each { |t| Trainees::UpdateIttData.call(trainee: t) }
    end

    def trainees
      @trainees ||= recommendations_upload.awardable_rows.map(&:trainee)
    end
  end
end
