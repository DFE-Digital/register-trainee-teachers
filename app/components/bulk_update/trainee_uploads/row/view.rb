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
            status_label
          end
        end

        def upload_path
          {
            "uploaded" => bulk_update_add_trainees_upload_path(upload),
            "pending" => bulk_update_add_trainees_upload_path(upload),
            "validated" => bulk_update_add_trainees_upload_path(upload),
            "succeeded" => bulk_update_add_trainees_upload_path(upload),
            "in_progress" => bulk_update_add_trainees_upload_path(upload),
            "failed" => bulk_update_add_trainees_upload_path(upload),
          }[upload.status]
        end

        def created_at
          upload.created_at.to_fs(:govuk_date_and_time)
        end

      private

        def status_label
          I18n.t(
            "bulk_updates.trainee_uploads.row.view.statuses.#{upload.status}",
            default: upload.status.humanize,
          )
        end
      end
    end
  end
end
