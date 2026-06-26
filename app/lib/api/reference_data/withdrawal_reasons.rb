# frozen_string_literal: true

module Api
  module ReferenceData
    class WithdrawalReasons
      METADATA = {
        name: "withdrawal_reasons",
        display_name: "Withdrawal reasons",
      }.freeze

      def self.payload
        {
          metadata: METADATA,
          triggers: TraineeWithdrawal.triggers.keys,
          future_interest: TraineeWithdrawal.future_interests.keys,
          entries: entries,
        }
      end

      def self.entries
        provider_entries + trainee_entries
      end

      def self.provider_entries
        ::WithdrawalReasons::PROVIDER_REASONS.map { |slug| entry_for(slug, "provider") }
      end

      def self.trainee_entries
        ::WithdrawalReasons::TRAINEE_REASONS.map { |slug| entry_for(slug, "trainee") }
      end

      def self.entry_for(slug, trigger)
        {
          slug: slug,
          display_name: I18n.t("components.withdrawal_details.reasons.#{slug}"),
          trigger: trigger,
          requires_another_reason: slug.include?("another_reason"),
          requires_safeguarding_concern_reasons: slug == ::WithdrawalReasons::SAFEGUARDING_CONCERNS,
        }
      end
    end
  end
end
