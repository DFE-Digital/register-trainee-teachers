# frozen_string_literal: true

module Api
  module V01
    class WithdrawalAttributes
      include ActiveModel::AttributeAssignment
      include ActiveModel::Attributes
      include ActiveModel::Model

      include DatesHelper

      validate :withdraw_date_valid
      validates :withdraw_reasons_details, length: { maximum: 1000 }, allow_blank: true
      validates :withdraw_reasons_dfe_details, length: { maximum: 1000 }, allow_blank: true
      validates :reasons, inclusion: { in: WithdrawalReasons::REASONS }

      validate :unknown_exclusively

      attr_accessor :trainee

      ATTRIBUTES = %i[
        reasons
        withdraw_date
        withdraw_reasons_details
        withdraw_reasons_dfe_details
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

      def unknown_exclusively
        return unless unknown_reason? && withdrawal_reasons.count > 1

        errors.add(:reasons, :unknown_exclusively)
      end

      def unknown_reason?
        withdrawal_reasons.pluck(:name).include?(WithdrawalReasons::UNKNOWN)
      end

      def withdrawal_reasons
        @withdrawal_reasons ||= WithdrawalReason.where(name: reasons)
      end
    end
  end
end
