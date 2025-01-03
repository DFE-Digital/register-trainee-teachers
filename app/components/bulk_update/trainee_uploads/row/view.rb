# frozen_string_literal: true

module BulkUpdate
  module TraineeUploads
    module Row
      class View < ViewComponent::Base
        include Rails.application.routes.url_helpers

        COLOURS = {
          "pending" => "govuk-tag--light-blue",
          "validated" => "govuk-tag--turquoise",
          "in_progress" => "govuk-tag--blue",
          "succeeded" => "govuk-tag--green",
          "failed" => "govuk-tag--red",
          "cancelled" => "govuk-tag--yellow",
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
          {
            "succeeded" => bulk_update_add_trainees_details_path(upload),
            "in_progress" => bulk_update_add_trainees_submission_path(upload),
            "failed" => bulk_update_add_trainees_review_error_path(upload),
          }[upload.status]
        end

        def submitted_at
          upload.submitted_at&.to_fs(:govuk_date_and_time)
        end
      end
    end
  end
end
