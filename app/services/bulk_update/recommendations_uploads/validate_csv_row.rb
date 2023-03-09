# frozen_string_literal: true

module BulkUpdate
  module RecommendationsUploads
    class ValidateCsvRow
      def initialize(row:, trainee:)
        @row = row
        @trainee = trainee
        @messages = []

        cannot_be_blank!
        validate!
      end

      def valid?
        messages.empty?
      end

      attr_reader :messages, :row

    private

      attr_reader :trainee

      def cannot_be_blank!
        %i[
          first_names
          last_names
          lead_school
          qts_or_eyts
          route
          phase
          age_range
          subject
        ].each do |attribute|
          next if row.send(attribute).presnt?

          @messages << "#{attribute.humanize} cannot be blank"
        end
      end

      def validate!
        trn
        hesa_id
        standards_met_at
        return unless trainee

        names
        qts_or_eyts
        route
        phase
        subject
      end

      def trn
        return if row.trn =~ /^\d{7}$/

        @messages << "TRN must be 7 characters long and contain only numbers"
      end

      def hesa_id
        return if row.hesa_id.nil?
        return if row.hesa_id =~ /^\d{17}$/

        @messages << "HESA ID must be 17 characters long and contain only numbers"
      end

      def standards_met_at
        if row.standards_met_at =~ /\A\d{1,2}\/\d{1,2}\/\d{4}\z/
          date = row.standards_met_at&.to_date
          if date && date > Time.zone.today
            @messages << "Award date must not be in the future (#{date.iso8601})"
          elsif date && date < 12.months.ago
            @messages << "Award date cannot be from more that 12 months ago #{12.months.ago.to_date.iso8601} (#{date.iso8601})"
          end
        else
          @messages << "Date could not be parsed, please use the format dd/mm/yyyy e.g. 27/02/2022"
        end
      end

      def names
        @messages << "Trainee name does not match" unless trainee.full_name.downcase == row.full_name.downcase
      end

      def qts_or_eyts
        @messages << "QTS/EYTS declaration does not match" unless trainee.award_type == row.qts_or_eyts
      end

      def route
        @messages << "Route does not match" unless trainee.training_route == row.route
      end

      def phase
        @messages << "Phase does not match" unless trainee.phase == row.phase
      end

      def subject
        @messages << "Subject does not match" unless trainee.subject == row.subject
      end
    end
  end
end
