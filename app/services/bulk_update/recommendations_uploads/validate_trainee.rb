# frozen_string_literal: true

module BulkUpdate
  module RecommendationsUploads
    # finds and validates a trainee scoped within provider, via trn/hesa/provider_trainee_id
    class ValidateTrainee
      include Config

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
        return @messages << error_message(:multiple_trainees_trn_received, count: trainees.count, found_with: found_with) if trainees.size > 1
        # otherwise check if multiple in non-draft non-trn-received were found
        return @messages << error_message(:multiple_trainees_found_via, count: trainees_not_trn_received.count, found_with: found_with) if trainees_not_trn_received.size > 1
        # otherwise check if one was found outside of non-draft, non-trn_received
        return @messages << error_message(:trainee_wrong_state, state: format_output(trainee_not_trn_received.state)) if trainee_not_trn_received

        @messages << error_message(:no_trainee_matched, id_available: id_columns)
      end

      def found_with
        { trn: "TRN", hesa_id: "HESA ID", provider_trainee_id: "the provider trainee ID" }[@found_with]
      end

      def trainees
        @trainees&.trn_received
      end

      def format_output(state)
        case state
        when "submitted_for_trn"
          "pending TRN"
        when "recommended_for_award"
          "#{trainee_not_trn_received.award_type} recommended"
        else
          state.gsub("_", " ")
        end
      end

      def trainees_not_trn_received
        return @trainees_not_trn_received if defined?(@trainees_not_trn_received)

        @trainees_not_trn_received = @trainees&.not_trn_received
      end

      def trainee_not_trn_received
        trainees_not_trn_received&.first if trainees_not_trn_received&.size == 1
      end

      # rubocop:disable Naming/MemoizedInstanceVariableName
      def trainees_by_trn!
        return unless row.trn =~ VALID_TRN

        @trainees ||= begin
          t = scope.where(trn: row.trn)
          @found_with = :trn if t.any?
          t
        end
      end

      def trainees_by_hesa_id!
        return unless row.hesa_id =~ VALID_HESA_ID

        @trainees ||= begin
          t = scope.where(hesa_id: row.sanitised_hesa_id)
          @found_with = :hesa_id if t.any?
          t
        end
      end

      def id_columns
        formatted = { trn: "TRN", hesa_id: "HESA ID", provider_trainee_id: "provider trainee ID" }
        output = []
        %i[trn hesa_id provider_trainee_id].each do |field|
          output << formatted[field] if row.public_send(field)
        end
        if output.length == 1 && output.include?("provider trainee ID")
          output[0] = "Provider trainee ID"
        end
        output.length > 1 ? "#{output[0..-2].join(', ')} or #{output.last}" : output.join
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
        I18n.t("activemodel.errors.models.bulk_update.recommendations_uploads.validate_trainee.#{key}", **variables)
      end
    end
  end
end
