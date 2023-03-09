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

      def trainee
        @trainees.first if @trainees.size == 1
      end

      def valid?
        @messages.empty?
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
        @messages << "Multiple trainees found via #{found_with}" if @trainees.size > 1
        @messages << "No trainee could be matched" if @trainees.zero?
      end

      def found_with
        { trn: "TRN", hesa: "HESA ID", provider_trainee_id: "the provider trainee ID" }[@found_with]
      end

      # rubocop:disable Naming/MemoizedInstanceVariableName
      def trainees_by_trn!
        return unless row.trn =~ /^\d{7}$/

        @trainees ||= begin
          t = provider.trainees.where(trn: row.trn)
          @found_with = :trn if t.any?
          t
        end
      end

      def trainees_by_hesa_id!
        return unless row.hesa_id =~ /^\d{17}$/

        @trainees ||= begin
          t = provider.trainees.where(hesa_id: row.hesa_id)
          @found_with = :hesa_id if t.any?
          t
        end
      end

      def trainees_by_provider_trainee_id!
        @trainees ||= begin
          t = provider.trainees.where(trainee_id: row.provider_trainee_id)
          @found_with = :provider_trainee_id if t.any?
          t
        end
      end
      # rubocop:enable Naming/MemoizedInstanceVariableName
    end
  end
end
