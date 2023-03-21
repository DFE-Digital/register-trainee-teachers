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
        trn
        hesa_id
        standards_met_at
        return unless trainee

        first_names
        last_names
        lead_school
        qts_or_eyts
        route
        phase
        age_range
        subject
      end

      def trn
        return if row.trn.blank?
        return if row.trn =~ /^\d{7}$/

        @messages << error_message(:trn)
      end

      def hesa_id
        return if row.hesa_id.nil?
        return if row.hesa_id =~ /^[0-9]{13}([0-9]{4})?$/

        @messages << error_message(:hesa_id)
      end

      def standards_met_at
        case row.standards_met_at
        when /^\d{1,2}[\/-]\d{1,2}[\/-]\d{4}$/ # dd/mm/yyyy or dd-mm-yyyy or d/m/yyyy etc etc
          date = row.standards_met_at.to_date
          today = Time.zone.today
          ago_12_months = 12.months.ago.to_date

          @messages << error_message(:award_date_future, date: date.strftime(Date::DATE_FORMATS[:govuk])) if date > today
          @messages << error_message(:award_date_past, date: ago_12_months.strftime(Date::DATE_FORMATS[:govuk])) if date < ago_12_months
          @messages << error_message(:date_standards_met, date: trainee.itt_start_date.strftime(Date::DATE_FORMATS[:govuk])) if trainee && date < trainee.itt_start_date
        else
          @messages << error_message(:date_parse)
        end
      end

      def column_exists?(column_name)
        csv.headers.include?(column_name)
      end

      def first_names
        return unless column_exists?(Reports::BulkRecommendReport::FIRST_NAME)

        # UnicodeUtils is used to remove accented characters for a simpler/more reliable comparison
        if UnicodeUtils.ascii_string(trainee.first_names.downcase) != UnicodeUtils.ascii_string(row.first_names.downcase)
          @messages << error_message(:first_names)
        end
      end

      def last_names
        return unless column_exists?(Reports::BulkRecommendReport::LAST_NAME)

        # UnicodeUtils is used to remove accented characters for a simpler/more reliable comparison
        if UnicodeUtils.ascii_string(trainee.last_names.downcase) != UnicodeUtils.ascii_string(row.last_names.downcase)
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
        return unless column_exists?(Reports::BulkRecommendReport::AGE_RANGE)

        @messages << error_message(:subject) if trainee.subjects != row.subject
      end

      def error_message(key, variables = {})
        I18n.t("activemodel.errors.models.bulk_update.recommendations_uploads.validate_csv_row.#{key}", variables)
      end
    end
  end
end
