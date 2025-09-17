# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class ImportRows
      include ServicePattern
      include ParseAddTraineeCsv

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
        "Disability 1" => "disability1",
        "Disability 2" => "disability2",
        "Disability 3" => "disability3",
        "Disability 4" => "disability4",
        "Disability 5" => "disability5",
        "Disability 6" => "disability6",
        "Disability 7" => "disability7",
        "Disability 8" => "disability8",
        "Disability 9" => "disability9",
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
        "Placement 1 URN" => "placement_urn1",
        "Placement 2 URN" => "placement_urn2",
        "Placement 3 URN" => "placement_urn3",
      }.freeze

      DEGREE_HEADERS = {
        "UK Degree Type" => "uk_degree",
        "Non-UK Degree Type" => "non_uk_degree",
        "Degree Subject" => "subject",
        "Degree Grade" => "grade",
        "Degree Graduation Year" => "graduation_year",
        "Awarding Institution" => "institution",
        "Degree Country" => "country",
      }.freeze

      ALL_HEADERS = TRAINEE_HEADERS.merge(PLACEMENT_HEADERS).merge(DEGREE_HEADERS)

      CASE_INSENSITIVE_ALL_HEADERS = ALL_HEADERS.to_h { |key, _| [key.downcase, key] }.freeze

      PREFIXED_HEADERS = [
        "HESA ID",
        "Date of Birth",
        "Sex",
        "Ethnicity",
        "Disability 1",
        "Disability 2",
        "Disability 3",
        "Disability 4",
        "Disability 5",
        "Disability 6",
        "Disability 7",
        "Disability 8",
        "Disability 9",
        "ITT Aim",
        "Training Route",
        "Qualification Aim",
        "Course Subject One",
        "Course Subject Two",
        "Course Subject Three",
        "Study Mode",
        "ITT Start Date",
        "ITT End Date",
        "Course Age Range",
        "Trainee Start Date",
        "PG Apprenticeship Start Date",
        "Fund Code",
        "Funding Method",
        "Training Initiative",
        "Additional Training Initiative",
        "UK Degree Type",
        "Non-UK Degree Type",
        "Degree Subject",
        "Degree Grade",
        "Degree Graduation Year",
        "Awarding Institution",
      ].freeze

      def call
        return unless FeatureService.enabled?(:bulk_add_trainees)

        dry_run = !trainee_upload.in_progress?
        success = true
        results = []

        ActiveRecord::Base.transaction do
          if dry_run
            file_content = trainee_upload.download.force_encoding(BulkUpdate::AddTrainees::Config::ENCODING)

            CSV.parse(
              file_content,
              headers: true,
              header_converters: ->(h) { convert_to_case_sensitive(h) },
            ).reject { |entry| entry.to_h.values.all?(&:blank?) }.each_with_index do |row, index|
              BulkUpdate::TraineeUploadRow.create!(
                trainee_upload: trainee_upload,
                data: row.to_h,
                row_number: index + 1,
              )
            end
          end

          ActiveRecord::Base.transaction(requires_new: true) do
            results = trainee_upload.trainee_upload_rows.map do |upload_row|
              BulkUpdate::AddTrainees::ImportRow.call(
                row: upload_row.data,
                current_provider: current_provider,
              )
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

        if !dry_run && success
          Trainee.where(slug: results.pluck(:slug)).find_each do |trainee|
            Trainees::SubmitForTrn.call(trainee:)
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
          nil,
          false,
          ["runtime failure: #{exception.message}"],
        )
      end
    end
  end
end
