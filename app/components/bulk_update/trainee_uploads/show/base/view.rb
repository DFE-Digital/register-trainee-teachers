# frozen_string_literal: true

module BulkUpdate
  module TraineeUploads
    module Show
      module Base
        class View < ViewComponent::Base
          include Rails.application.routes.url_helpers
          include OrganisationHelper
          include ApplicationHelper

          attr_reader :upload

          def initialize(upload:)
            @upload = upload
          end
        end
      end
    end
  end
end
