# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class ImportRows
      include ServicePattern

      attr_accessor :trainee_upload

      def initialize(trainee_upload)
        self.trainee_upload = trainee_upload
      end

      EMPTY_CSV_TEMPLATE_PATH = "/csv/bulk_create_trainee.csv"

      TRAINEE_HEADERS = {
        "Provider Trainee ID" => "provider_trainee_id",
        "Application ID" => "application_id",
        "HESA ID" => "hesa_id",
        "First Names" => "first_names",
        "Last Name" => "last_name",
        "Previous Last Name" => "previous_last_name",
        "Date of Birth" => "date_of_birth",
        "NI Number" => "ni_number",
        "Sex" => "sex",
        "Email" => "email",
        "Nationality" => "nationality",
        "Ethnicity" => "ethnicity",
        "Disability 1" => "disability_1",
        "Disability 2" => "disability_2",
        "Disability 3" => "disability_3",
        "Disability 4" => "disability_4",
        "Disability 5" => "disability_5",
        "Disability 6" => "disability_6",
        "Disability 7" => "disability_7",
        "Disability 8" => "disability_8",
        "Disability 9" => "disability_9",
        "ITT Aim" => "itt_aim",
        "Training Route" => "training_route",
        "Qualification Aim" => "itt_qualification_aim",
        "Course Subject One" => "course_subject_one",
        "Course Subject Two" => "course_subject_two",
        "Course Subject Three" => "course_subject_three",
        "Study Mode" => "study_mode",
        "ITT Start Date" => "itt_start_date",
        "ITT End Date" => "itt_end_date",
        "Course Age Range" => "course_age_range",
        "Course Year" => "course_year",
        "Lead Partner URN" => "lead_partner_urn",
        "Employing School URN" => "employing_school_urn",
        "Trainee Start Date" => "trainee_start_date",
        "PG Apprenticeship Start Date" => "pg_apprenticeship_start_date",
        "Fund Code" => "fund_code",
        "Funding Method" => "funding_method",
        "Training Initiative" => "training_initiative",
        "Additional Training Initiative" => "additional_training_initiative",
      }.freeze

      PLACEMENT_HEADERS = {
        "First Placement URN" => "urn",
      }.freeze

      DEGREE_HEADERS = {
        "UK Degree Type" => "uk_degree_type",
        "Non-UK Degree Type" => "non_uk_degree_type",
        "Degree Subject" => "degree_subject",
        "Degree Grade" => "degree_grade",
        "Degree Graduation Year" => "degree_graduation_year",
        "Awarding Institution" => "degree_awarding_institution",
        "Degree Country" => "degree_country",
      }.freeze

      ALL_HEADERS = TRAINEE_HEADERS.merge(PLACEMENT_HEADERS).merge(DEGREE_HEADERS)

      def call
        return unless FeatureService.enabled?(:bulk_add_trainees)

        dry_run = !trainee_upload.in_progress?
        success = true

        ActiveRecord::Base.transaction do |_transaction|
          if dry_run
            CSV.parse(trainee_upload.file.download, headers: true).reject { |entry| entry.to_h.values.all?(&:blank?) }.map.with_index do |row, index|
              BulkUpdate::TraineeUploadRow.create!(
                trainee_upload: trainee_upload,
                data: row.to_h,
                row_number: index + 1,
              )
            end
          end

          results = []

          ActiveRecord::Base.transaction(requires_new: true) do
            results = trainee_upload.trainee_upload_rows.map do |upload_row|
              BulkUpdate::AddTrainees::ImportRow.call(row: upload_row.data, current_provider: current_provider)
            rescue StandardError => e
              capture_exception(e)
            end

            # Commit or rollback the transaction depending on whether all rows were error free
            if results.all?(&:success)
              trainee_upload.succeed! unless dry_run
            else
              success = false
            end

            raise(ActiveRecord::Rollback) if dry_run || !success
          end

          if !success
            trainee_upload.fail!
            create_row_errors(results)
          elsif dry_run
            trainee_upload.process!
          end
        end

        success
      rescue ActiveRecord::ActiveRecordError
        trainee_upload.fail!

        raise
      end

    private

      def current_provider
        @current_provider ||= trainee_upload.provider
      end

      def create_row_errors(results)
        trainee_upload.trainee_upload_rows.each_with_index do |upload_row, index|
          next if results[index].success

          error_type = results[index].error_type
          extract_error_messages(errors: results[index].errors).each do |message|
            upload_row.row_errors.create!(message:, error_type:)
          end
        end
      end

      def extract_error_messages(messages = [], errors:)
        values = errors.respond_to?(:values) ? errors.values : errors

        values.each do |value|
          if value.is_a?(Hash) || value.is_a?(Array)
            extract_error_messages(messages, errors: value)
          else
            messages << value
          end
        end

        messages
      end

      def capture_exception(exception)
        Sentry.capture_exception(
          exception,
          extra: {
            provider_id: trainee_upload.provider_id,
            user_id: trainee_upload.submitted_by_id,
          },
        )
        BulkUpdate::AddTrainees::ImportRow::Result.new(
          false,
          ["runtime failure: #{exception.message}"],
        )
      end
    end
  end
end
