# frozen_string_literal: true

module BulkUpdate
  module TraineeUploads
    module Row
      class View < ViewComponent::Base
        COLOURS = {
          "pending" => "govuk-tag--light-blue",
          "validated" => "govuk-tag--turquoise",
          "in_progress" => "govuk-tag--blue",
          "succeeded" => "govuk-tag--green",
          "failed" => "govuk-tag--red",
          "cancelled" => "govuk-tag--yellow",
        }.freeze

        PATHS = {
          "succeeded" => lambda do |upload|
            Rails.application.routes.url_helpers.bulk_update_trainees_details_path(upload)
          end,
          "in_progress" => lambda do |upload|
            Rails.application.routes.url_helpers.bulk_update_trainees_submission_path(upload)
          end,
          "failed" => lambda do |upload|
            Rails.application.routes.url_helpers.bulk_update_trainees_review_error_path(upload)
          end,
        }.freeze

        attr_reader :upload

        delegate :filename, to: :upload

        def initialize(upload:)
          @upload = upload
        end

        def status
          content_tag(:span, class: "govuk-tag #{COLOURS[upload.status]}") do
            upload.status.humanize
          end
        end

        def upload_path
          PATHS[upload.status]&.call(upload)
        end

        def submitted_at
          upload.submitted_at&.to_fs(:govuk_date_and_time)
        end
      end
    end
  end
end
