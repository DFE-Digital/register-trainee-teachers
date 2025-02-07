# frozen_string_literal: true

module BulkUpdate
  module TraineeUploads
    module Show
      module Base
        class View < ViewComponent::Base
          include Rails.application.routes.url_helpers
          include OrganisationHelper
          include ApplicationHelper

          attr_reader :upload, :current_user

          def initialize(upload:, current_user: nil)
            @upload = upload
            @current_user = current_user
          end
        end
      end
    end
  end
end
