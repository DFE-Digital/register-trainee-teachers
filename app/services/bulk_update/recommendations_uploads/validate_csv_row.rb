# frozen_string_literal: true

module BulkUpdate
  module RecommendationsUploads
    class ValidateCsvRow
      include Config

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

      attr_reader :messages, :date

    private

      attr_reader :trainee, :csv, :row

      def validate!
        if row.empty?
          return
        end

        trn_format
        hesa_id_format
        standards_met_at
        return unless trainee

        trn
        hesa_id
        provider_trainee_id
        first_names
        last_names
        training_partner
        qts_or_eyts
        route
        phase
        age_range
        subject
      rescue StandardError
        @messages << error_message(:unexpected_error)
      end

      def trn_format
        return if row.trn.blank?
        return if row.trn =~ VALID_TRN

        @messages << error_message(:trn_format)
      end

      def hesa_id_format
        return if row.hesa_id.nil?
        return if row.hesa_id =~ VALID_HESA_ID

        @messages << error_message(:hesa_id_format)
      end

      def standards_met_at
        case row.standards_met_at
        when VALID_STANDARDS_MET_AT
          return @messages << error_message(:award_date_not_valid) unless valid_date?(row.standards_met_at)

          @date = row.standards_met_at.to_date
          today = Time.zone.today.to_date
          ago_12_months = 12.months.ago.to_date

          @messages << error_message(:award_date_future, date: gds_date(date)) if @date > today
          @messages << error_message(:award_date_past, date: gds_date(ago_12_months)) if @date < ago_12_months
          @messages << error_message(:date_standards_met, date: gds_date(trainee.itt_start_date.to_date)) if trainee&.itt_start_date && @date < trainee.itt_start_date.to_date
        else
          @messages << error_message(:date_parse) if row.standards_met_at.present?
        end
      end

      def gds_date(date)
        date.strftime(Date::DATE_FORMATS[:govuk])
      end

      def valid_date?(date_str)
        Date.strptime(date_str, "%d/%m/%Y")
        true
      rescue ArgumentError
        false
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

        @messages << error_message(:hesa_id) if trainee.sanitised_hesa_id != row.sanitised_hesa_id
      end

      def provider_trainee_id
        return unless column_exists?(Reports::BulkRecommendReport::PROVIDER_TRAINEE_ID)

        @messages << error_message(:provider_trainee_id) if trainee.provider_trainee_id&.downcase != row.provider_trainee_id&.downcase
      end

      def first_names
        return unless column_exists?(Reports::BulkRecommendReport::FIRST_NAME)

        if transliterate(trainee.first_names) != transliterate(row.first_names)
          @messages << error_message(:first_names)
        end
      end

      def last_names
        return unless column_exists?(Reports::BulkRecommendReport::LAST_NAME)

        if transliterate(trainee.last_names) != transliterate(row.last_names)
          @messages << error_message(:last_names)
        end
      end

      def training_partner
        return unless column_exists?(Reports::BulkRecommendReport::TRAINING_PARTNER)

        @messages << error_message(:training_partner) if trainee.training_partner_name&.downcase != row.training_partner&.downcase
      end

      def qts_or_eyts
        return unless column_exists?(Reports::BulkRecommendReport::QTS_OR_EYTS)

        @messages << error_message(:qts_or_eyts) if trainee.qts_or_eyts.downcase != row.qts_or_eyts&.downcase
      end

      def route
        return unless column_exists?(Reports::BulkRecommendReport::ROUTE)

        @messages << error_message(:route) if trainee.course_training_route.downcase != row.route&.downcase
      end

      def phase
        return unless column_exists?(Reports::BulkRecommendReport::PHASE)

        @messages << error_message(:phase) if trainee.course_education_phase&.downcase != row.phase&.downcase
      end

      def age_range
        return unless column_exists?(Reports::BulkRecommendReport::AGE_RANGE)

        @messages << error_message(:age_range) if trainee.course_age_range&.downcase != row.age_range&.downcase
      end

      def subject
        return unless column_exists?(Reports::BulkRecommendReport::SUBJECT)

        @messages << error_message(:subject) if trainee.subjects&.downcase != row.subject&.downcase
      end

      # Used to remove accented characters for a simpler/more reliable comparison
      def transliterate(string)
        return unless string

        I18n.transliterate(string.dup.force_encoding(ENCODING), replacement: "")&.downcase
      rescue ArgumentError
        @messages << error_message(:transliteration, string:)
      end

      def error_message(key, variables = {})
        I18n.t("activemodel.errors.models.bulk_update.recommendations_uploads.validate_csv_row.#{key}", **variables)
      end
    end
  end
end
