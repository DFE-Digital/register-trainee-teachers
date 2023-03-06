# frozen_string_literal: true

module BulkUpdate
  module RecommendationsUploads
    class ValidateCsvRow
      def initialize(row)
        @row = OpenStruct.new(
          trn: row["trn"],
          hesa_id: row["heas id"],
          provider_trainee_id: row["provider trainee id"],
          last_names: row["last names"],
          first_names: row["first names"],
          lead_school: row["lead school"],
          qts_or_eyts: row["qts or eyts"],
          route: row["route"],
          phase: row["phase"],
          age_range: row["age range"],
          subject: row["subject"],
          standards_met_at: row["date qts or eyts standards met"],
        )
        @messages = []

        validate!
      end

      def valid?
        messages.any?
      end

      attr_reader :messages, :row

    private

      def validate!
        trn
        hesa_id
        standards_met_at
      end

      def trn
        return if row.trn =~ /^\d{7}$/

        @messages << "TRN must be 7 characters long and contain only numbers"
      end

      def hesa_id
        return if row.hesa_id =~ /^\d{17}$/

        @messages << "HESA ID must be 17 characters long and contain only numbers"
      end

      def standards_met_at
        date = row.standards_met_at&.to_date
        if date && date > Time.zone.today
          @messages << "Award date must not be in the future"
        elsif date && date < 12.months.ago
          @messages << "Award date cannot be from more that 12 months ago #{12.months.ago.to_date.iso8601}"
        end
      rescue Date::Error
        @messages << "Date could not be parsed, please use the format dd/mm/yyyy e.g. 27/02/2022"
      end
    end
  end
end
