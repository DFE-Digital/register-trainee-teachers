# frozen_string_literal: true

module BulkUpdate
  module TraineeUploads
    module Show
      module Base
        class View < ApplicationComponent
          include Rails.application.routes.url_helpers
          include OrganisationHelper
          include ApplicationHelper

          attr_reader :upload, :current_user, :bulk_add_trainee_upload_form

          def initialize(upload:, current_user: nil, bulk_add_trainee_upload_form: nil)
            @upload = upload
            @current_user = current_user
            @bulk_add_trainee_upload_form = bulk_add_trainee_upload_form
          end
        end
      end
    end
  end
end
