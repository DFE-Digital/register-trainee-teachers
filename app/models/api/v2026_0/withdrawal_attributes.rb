# frozen_string_literal: true

module Api
  module V20260
    class WithdrawalAttributes
      include ActiveModel::AttributeAssignment
      include ActiveModel::Attributes
      include ActiveModel::Model
      include Api::ErrorAttributeAdapter

      include DatesHelper

      validate :withdrawal_date_valid
      validate :withdrawal_reasons_valid?, unless: -> { reasons.nil? }
      validate :withdrawal_reasons_provided?
      validates :trigger, inclusion: { in: TraineeWithdrawal.triggers.keys }
      validates :future_interest, inclusion: { in: TraineeWithdrawal.future_interests.keys }
      validates :another_reason, presence: { if: -> { reasons&.any? { |x| x.include?("another_reason") } } }
      validates :safeguarding_concern_reasons, presence: { if: -> { reasons&.include?("safeguarding_concerns") } }

      attr_accessor :trainee

      ATTRIBUTES = %i[
        reasons
        withdrawal_date
        trigger
        future_interest
        another_reason
        safeguarding_concern_reasons
      ].freeze

      ATTRIBUTES.each do |attr|
        attribute attr
      end

      attribute :record_source, default: -> { Trainee::API_SOURCE }

      def initialize(trainee:)
        @trainee = trainee

        super
      end

      def attributes_to_save
        attributes
          .symbolize_keys
          .except(:record_source, :reasons, :withdrawal_date)
          .merge(withdrawal_reasons:, withdraw_date: withdrawal_date)
      end

    private

      def withdrawal_date_valid
        if withdrawal_date.blank?
          errors.add(:withdrawal_date, :blank)
        elsif parsed_withdrawal_date.blank?
          errors.add(:withdrawal_date, :invalid)
        elsif date_before_itt_start_date?(parsed_withdrawal_date, trainee.itt_start_date)
          errors.add(:withdrawal_date, :not_before_itt_start_date)
        end
      end

      def parsed_withdrawal_date
        parsed_date = begin
          DateTime.iso8601(withdrawal_date)
        rescue StandardError
          ArgumentError
        end

        if parsed_date == ArgumentError
          nil
        else
          parsed_date
        end
      end

      def withdrawal_reasons_provided?
        errors.add(:reasons, :inclusion) if reasons.blank?
      end

      def withdrawal_reasons_valid?
        errors.add(:reasons, :invalid) unless (reasons - valid_reasons).empty?
      end

      def valid_reasons
        return WithdrawalReasons::PROVIDER_REASONS if trigger == "provider"

        WithdrawalReasons::TRAINEE_REASONS
      end

      def withdrawal_reasons
        @withdrawal_reasons ||= WithdrawalReason.where(name: reasons)
      end
    end
  end
end
