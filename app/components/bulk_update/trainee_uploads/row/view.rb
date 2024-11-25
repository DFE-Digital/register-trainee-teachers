# frozen_string_literal: true

module BulkUpdate
  module TraineeUploads
    module Row
      class View < ViewComponent::Base
        attr_reader :upload

        delegate :created_at, :filename, :status, to: :upload

        def initialize(upload:)
          @upload = upload
        end

        def status
          content_tag(:span, class: "govuk-tag #{colour}") do
            upload.status.humanize
          end
        end

      private

        def colour
          {
            "pending" => "govuk-tag--grey",
            "validated" => "govuk-tag--grey",
            "in_progress" => "govuk-tag--grey",
            "succeeded" => "govuk-tag--green",
            "failed" => "govuk-tag--red",
          }[upload.status]
        end
      end
    end
  end
end
