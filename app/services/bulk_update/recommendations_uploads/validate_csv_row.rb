# frozen_string_literal: true

module BulkUpdate
  module RecommendationsUploads
    class ValidateCsvRow
      def initialize(csv:, row:, trainee:)
        @csv = csv
        @row = row
        @trainee = (::Reports::TraineeReport.new(trainee) if trainee)
        @messages = []

        validate!
      end

      def valid?
        messages.empty?
      end

      attr_reader :messages

    private

      attr_reader :trainee, :csv, :row

      def validate!
        trn_format
        hesa_id_format
        standards_met_at
        return unless trainee

        trn
        hesa_id
        provider_trainee_id
        first_names
        last_names
        lead_school
        qts_or_eyts
        route
        phase
        age_range
        subject
      end

      def trn_format
        return if row.trn.blank?
        return if row.trn =~ /^\d{7}$/

        @messages << error_message(:trn_format)
      end

      def hesa_id_format
        return if row.hesa_id.nil?
        return if row.hesa_id =~ /^[0-9]{13}([0-9]{4})?$/

        @messages << error_message(:hesa_id_format)
      end

      def standards_met_at
        case row.standards_met_at
        when /^\d{1,2}[\/-]\d{1,2}[\/-]\d{4}$/ # dd/mm/yyyy or dd-mm-yyyy or d/m/yyyy etc etc
          date = row.standards_met_at.to_date
          today = Time.zone.today.to_date
          ago_12_months = 12.months.ago.to_date

          @messages << error_message(:award_date_future, date: gds_date(date)) if date > today
          @messages << error_message(:award_date_past, date: gds_date(ago_12_months)) if date < ago_12_months
          @messages << error_message(:date_standards_met, date: gds_date(trainee.itt_start_date.to_date)) if trainee&.itt_start_date && date < trainee.itt_start_date.to_date
        else
          @messages << error_message(:date_parse)
        end
      end

      def gds_date(date)
        date.strftime(Date::DATE_FORMATS[:govuk])
      end

      def column_exists?(column_name)
        csv.headers.include?(column_name.downcase)
      end

      def trn
        return unless column_exists?(Reports::BulkRecommendReport::TRN)

        @messages << error_message(:trn) if trainee.trn != row.trn
      end

      def hesa_id
        return unless column_exists?(Reports::BulkRecommendReport::HESA_ID)

        @messages << error_message(:hesa_id) if trainee.hesa_id != row.hesa_id
      end

      def provider_trainee_id
        return unless column_exists?(Reports::BulkRecommendReport::TRAINEE_ID)

        @messages << error_message(:provider_trainee_id) if trainee.provider_trainee_id != row.provider_trainee_id
      end

      def first_names
        return unless column_exists?(Reports::BulkRecommendReport::FIRST_NAME)

        # UnicodeUtils is used to remove accented characters for a simpler/more reliable comparison
        if I18n.transliterate(trainee.first_names.downcase, replacement: "") != I18n.transliterate(row.first_names.downcase, replacement: "")
          @messages << error_message(:first_names)
        end
      end

      def last_names
        return unless column_exists?(Reports::BulkRecommendReport::LAST_NAME)

        # UnicodeUtils is used to remove accented characters for a simpler/more reliable comparison
        if I18n.transliterate(trainee.last_names.downcase, replacement: "") != I18n.transliterate(row.last_names.downcase, replacement: "")
          @messages << error_message(:last_names)
        end
      end

      def lead_school
        return unless column_exists?(Reports::BulkRecommendReport::LEAD_SCHOOL)

        @messages << error_message(:lead_school) if (trainee.lead_school_name || "-") != row.lead_school
      end

      def qts_or_eyts
        return unless column_exists?(Reports::BulkRecommendReport::QTS_OR_EYTS)

        @messages << error_message(:qts_or_eyts) if trainee.qts_or_eyts != row.qts_or_eyts
      end

      def route
        return unless column_exists?(Reports::BulkRecommendReport::ROUTE)

        @messages << error_message(:route) if trainee.course_training_route != row.route
      end

      def phase
        return unless column_exists?(Reports::BulkRecommendReport::PHASE)

        @messages << error_message(:phase) if trainee.course_education_phase != row.phase
      end

      def age_range
        return unless column_exists?(Reports::BulkRecommendReport::AGE_RANGE)

        @messages << error_message(:age_range) if trainee.course_age_range != row.age_range
      end

      def subject
        return unless column_exists?(Reports::BulkRecommendReport::SUBJECT)

        @messages << error_message(:subject) if trainee.subjects != row.subject
      end

      def error_message(key, variables = {})
        I18n.t("activemodel.errors.models.bulk_update.recommendations_uploads.validate_csv_row.#{key}", **variables)
      end
    end
  end
end
