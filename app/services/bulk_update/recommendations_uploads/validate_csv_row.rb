# frozen_string_literal: true

module BulkUpdate
  module RecommendationsUploads
    class ValidateCsvRow
      def initialize(row:, trainee:)
        @row = row
        @trainee = (::Reports::TraineeReport.new(trainee) if trainee)
        @messages = []

        validate_presence!
        validate!
      end

      def valid?
        messages.empty?
      end

      attr_reader :messages, :row

    private

      attr_reader :trainee

      def validate_presence!
        %i[
          trn
          first_names
          last_names
          lead_school
          qts_or_eyts
          route
          phase
          age_range
          subject
        ].each do |attribute|
          next if row.send(attribute).present?

          @messages << "\"#{attribute.to_s.humanize.titleize}\" cannot be blank"
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
      end

      def trn
        return if row.trn.blank?
        return if row.trn =~ /^\d{7}$/

        @messages << "TRN must be 7 characters long and contain only numbers"
      end

      def hesa_id
        return if row.hesa_id.nil?
        return if row.hesa_id =~ /^[0-9]{13}([0-9]{4})?$/

        @messages << "HESA ID must be 13 or 17 characters long and contain only numbers"
      end

      def standards_met_at
        # dd/mm/yyyy or dd-mm-yyyy or d/m/yyyy etc etc
        if row.standards_met_at =~ /^\d{1,2}[\/-]\d{1,2}[\/-]\d{4}$/
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
        if row.first_names.present? && trainee.first_names.downcase != row.first_names.downcase
          @messages << "Trainee first names do not match"
        end
        if row.last_names.present? && trainee.last_names.downcase != row.last_names.downcase
          @messages << "Trainee last names do not match"
        end
      end

      def qts_or_eyts
        return if row.qts_or_eyts.blank?

        @messages << "QTS/EYTS declaration does not match" unless trainee.qts_or_eyts == row.qts_or_eyts
      end

      def route
        return if row.route.blank?

        @messages << "Route does not match" unless trainee.course_training_route == row.route
      end

      def phase
        return if row.phase.blank?

        @messages << "Phase does not match" unless trainee.course_education_phase == row.phase
      end
    end
  end
end
