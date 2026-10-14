# frozen_string_literal: true

module Api
  module V20270
    class AwardRecommendationService
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ServicePattern

      include Api::ErrorAttributeAdapter

      ATTRIBUTES = %i[qts_or_eyts_requirements_met_date].freeze

      attribute :qts_or_eyts_requirements_met_date
      attribute :record_source, default: -> { Trainee::API_SOURCE }

      attr_reader :trainee

      delegate :itt_start_date, :can_recommend_for_award?, :requires_degree?, :requires_placements?,
               :requires_assessment_only_employing_school?, :employing_school_recorded?, to: :trainee, prefix: true

      validates :qts_or_eyts_requirements_met_date,
                presence: true,
                date: true,
                date_relative_to_time: { future: false },
                after_itt_start_date: true

      validates_with Api::Trainees::AwardRecommendationValidator

      def initialize(params, trainee)
        super(params)

        @trainee = trainee
      end

      def call
        return false, errors unless valid?

        trainee.attributes = trainee_attributes
        trainee.recommend_for_award!

        ::Trainees::UpdateIttDataInTra.call(trainee:)

        true
      end

      def trainee_degree_missing?
        degrees.blank?
      end

      def trainee_placements_missing?
        placements.size < trainee.minimum_placements
      end

      def trainee_employing_school_missing?
        !trainee_employing_school_recorded?
      end

    private

      delegate :state, :degrees, :placements, to: :trainee

      alias_method :degree_id, :degrees

      def trainee_attributes
        {
          outcome_date: qts_or_eyts_requirements_met_date,
        }
      end
    end
  end
end
