# frozen_string_literal: true

module BulkUpdate
  module RecommendationsUploads
    # finds and validates a trainee scoped within provider, via trn/hesa/provider_trainee_id
    class ValidateTrainee
      include Config

      FIELD_MAP = {
        trn: "TRN",
        hesa_id: "HESA ID",
        provider_trainee_id: "provider trainee ID",
      }.freeze

      def initialize(row:, provider:, trainee_lookup:)
        @row = row
        @provider = provider
        @trainee_lookup = trainee_lookup
        @trainees = find_trainees
        @messages = []

        validate!
      end

      def valid?
        @messages.empty?
      end

      def trainee
        trainees_trn_received&.first if trainees_trn_received&.size == 1
      end

      attr_reader :messages

    private

      attr_reader :row, :provider, :trainee_lookup

      def validate!
        return if row.empty?
        return if trainee

        # if no singular trainee in state trn_recevied was found then check if there are multiple in trn_received
        if trainees_trn_received.size > 1
          return @messages << error_message(:multiple_trainees_trn_received,
                                            count: trainees_trn_received.count,
                                            found_with: found_with)
        end
        # otherwise check if multiple in non-draft non-trn-received were found
        if trainees_not_trn_received.size > 1
          return @messages << error_message(:multiple_trainees_found_via,
                                            count: trainees_not_trn_received.count,
                                            found_with: found_with)
        end
        # otherwise check if one was found outside of non-draft, non-trn_received
        if trainee_not_trn_received
          return @messages << error_message(:trainee_wrong_state,
                                            state: format_output(trainee_not_trn_received.state))
        end

        @messages << error_message(:no_trainee_matched, id_available: id_columns)
      end

      def found_with
        FIELD_MAP[@found_with]
      end

      def trainee_not_trn_received
        trainees_not_trn_received&.first if trainees_not_trn_received&.size == 1
      end

      def trainees_trn_received
        @trainees&.select(&:trn_received?)
      end

      def trainees_not_trn_received
        return @trainees_not_trn_received if defined?(@trainees_not_trn_received)

        @trainees_not_trn_received = @trainees&.reject(&:trn_received?)
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

      def id_columns
        output = []

        FIELD_MAP.each_key do |field|
          output << FIELD_MAP[field] if row.public_send(field)
        end

        if output.length == 1 && output.include?("provider trainee ID")
          output[0] = "Provider trainee ID"
        end

        output.length > 1 ? "#{output[0..-2]&.join(', ')} or #{output.last}" : output.join
      end

      def find_trainees
        trainees = []
        FIELD_MAP.each_key do |field|
          method_name = field == :hesa_id ? :sanitised_hesa_id : field
          trainees = trainee_lookup[row.public_send(method_name)]
          if trainees.present?
            @found_with = field
            break
          end
        end
        trainees
      end

      def error_message(key, variables = {})
        I18n.t("activemodel.errors.models.bulk_update.recommendations_uploads.validate_trainee.#{key}", **variables)
      end
    end
  end
end
