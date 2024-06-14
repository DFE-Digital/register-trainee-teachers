# frozen_string_literal: true

module Api
  module Trainees
    class AwardRecommendationService
      include ActiveModel::Model
      include ActiveModel::Attributes

      include ServicePattern

      attribute :outcome_date

      validates :outcome_date, presence: true, date: true
      validate :trainee_state

      def initialize(params, trainee)
        super(params)

        @trainee = trainee
      end

      def call
        trainee.attributes = trainee_attributes

        if valid? &&
            trainee.submission_ready? &&
            outcome_date_form.save! &&
            trainee.recommend_for_award!

          Dqt::RecommendForAwardJob.perform_later(trainee)

          [true]
        else
          promote_errors(outcome_date_form) if errors.blank?

          [false, errors]
        end
      end

    private

      attr_reader :trainee

      def trainee_attributes
        {
          outcome_date:,
        }
      end

      def trainee_state
        unless trainee.can_recommend_for_award?
          errors.add(:trainee, :state)
        end
      end

      def outcome_date_form
        @outcome_date_form ||= OutcomeDateForm.new(trainee, update_dqt: false)
      end

      def promote_errors(child)
        child.errors.each do |error|
          errors.add(:base, error.message)
        end
      end
    end
  end
end
