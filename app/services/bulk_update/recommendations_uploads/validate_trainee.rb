# frozen_string_literal: true

module BulkUpdate
  module RecommendationsUploads
    # finds and validates a trainee scoped within provider, via trn/hesa/provider_trainee_id
    class ValidateTrainee
      def initialize(row:, provider:)
        @row = row
        @provider = provider
        @messages = []

        find!
        validate!
      end

      def valid?
        @messages.empty?
      end

      def trainee
        trainees&.first if trainees&.size == 1
      end

      attr_reader :messages

    private

      attr_reader :row, :provider

      def find!
        trainees_by_trn!
        trainees_by_hesa_id!
        trainees_by_provider_trainee_id!
      end

      def validate!
        return if trainee
        # if no singular trainee in state trn_recevied was found then check if there are multiple in trn_received
        return @messages << error_message(:multiple_trainees_trn_recieved, found_with:) if trainees.size > 1
        # otherwise check if multiple in non-draft non-trn-received were found
        return @messages << error_message(:multiple_trainees_found_via, found_with:) if trainees_not_trn_received.size > 1
        # otherwise check if one was found outside of non-draft, non-trn_received
        return @messages << error_message(:multiple_trainees_found_via, state: trainee_not_trn_received.state.humanize) if trainee_not_trn_received

        @messages << error_message(:no_trainee_matched)
      end

      def found_with
        { trn: "TRN", hesa_id: "HESA ID", provider_trainee_id: "the provider trainee ID" }[@found_with]
      end

      def trainees
        return @trainees if defined?(@trainees)

        @trainees = @trainees&.where(state: :trn_received)
      end

      def trainees_not_trn_received
        return @trainees_not_trn_received if defined?(@trainees_not_trn_received)

        @trainees_not_trn_received = @trainees&.where&.not(state: :trn_received)
      end

      def trainee_not_trn_received
        trainees_not_trn_received&.first if trainees_not_trn_received&.size == 1
      end

      # rubocop:disable Naming/MemoizedInstanceVariableName
      def trainees_by_trn!
        return unless row.trn =~ /^\d{7}$/

        @trainees ||= begin
          t = scope.where(trn: row.trn)
          @found_with = :trn if t.any?
          t
        end
      end

      def trainees_by_hesa_id!
        return unless row.hesa_id =~ /^[0-9]{13}([0-9]{4})?$/

        @trainees ||= begin
          t = scope.where(hesa_id: row.hesa_id)
          @found_with = :hesa_id if t.any?
          t
        end
      end

      def trainees_by_provider_trainee_id!
        @trainees ||= begin
          t = scope.where(trainee_id: row.provider_trainee_id)
          @found_with = :provider_trainee_id if t.any?
          t
        end
      end
      # rubocop:enable Naming/MemoizedInstanceVariableName

      def scope
        @scope ||= provider.trainees.where.not(state: :draft)
      end

      def error_message(key, variables = {})
        I18n.t("activemodel.errors.models.bulk_update.recommendations_uploads.validate_trainee.#{key}", variables)
      end
    end
  end
end
