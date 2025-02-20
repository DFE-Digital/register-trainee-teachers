# frozen_string_literal: true

module Api
  module V01
    class WithdrawalAttributes
      include ActiveModel::AttributeAssignment
      include ActiveModel::Attributes
      include ActiveModel::Model

      include DatesHelper

      validate :withdraw_date_valid
      validates :reasons, presence: true
      validate :withdrawal_reasons_valid?
      validates :trigger, inclusion: { in: %w[provider trainee] }
      validates :future_interest, inclusion: { in: %w[yes no unknown] }

      attr_accessor :trainee

      ATTRIBUTES = %i[
        reasons
        withdraw_date
        trigger
        future_interest
      ].freeze

      ATTRIBUTES.each do |attr|
        attribute attr
      end

      def initialize(trainee:)
        @trainee = trainee
        super
      end

      def attributes_to_save
        attributes.symbolize_keys.except(:reasons).merge(withdrawal_reasons:)
      end

    private

      def withdraw_date_valid
        if withdraw_date.blank?
          errors.add(:withdraw_date, :blank)
        elsif parsed_withdraw_date.blank?
          errors.add(:withdraw_date, :invalid)
        elsif date_before_itt_start_date?(parsed_withdraw_date, trainee.itt_start_date)
          errors.add(:withdraw_date, :not_before_itt_start_date)
        end
      end

      def parsed_withdraw_date
        parsed_date = begin
          DateTime.iso8601(withdraw_date)
        rescue StandardError
          ArgumentError
        end

        if parsed_date == ArgumentError
          nil
        else
          parsed_date
        end
      end

      def withdrawal_reasons_valid?
        errors.add(:reasons, :inclusion) if reasons.blank? || reasons.empty?
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
