# frozen_string_literal: true

module Api
  module Trainees
    class DeferralValidator < ActiveModel::Validator
      def validate(record)
        return unless record.errors.empty?

        record.errors.add(:state) unless record.trainee_can_defer?
      end
    end
  end
end
