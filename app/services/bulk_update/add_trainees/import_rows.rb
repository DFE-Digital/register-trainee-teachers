# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class ImportRows
      include ServicePattern
      include ParseAddTraineeCsv

      def self.fields_definition_path
        version = module_parent_name.demodulize.underscore.insert(-2, "_")
        Rails.root.join("app/views/bulk_update/add_trainees/reference_docs/#{version}/fields.yaml")
      end

      attr_accessor :trainee_upload

      def initialize(trainee_upload)
        self.trainee_upload = trainee_upload
      end

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
              BulkUpdate::AddTrainees::VERSION::ImportRow.call(
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
        BulkUpdate::AddTrainees::VERSION::ImportRow::Result.new(
          nil,
          false,
          ["runtime failure: #{exception.message}"],
        )
      end
    end
  end
end
