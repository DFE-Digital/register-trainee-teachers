# frozen_string_literal: true

module BulkUpdate
  module Imports
    class TraineeUploadPolicy < TraineeUploads::BasePolicy
      def create?
        return user.accredited_hei_provider_or_hei_lead_partner? && trainee_upload.uploaded? if Rails.env.in?(%w[csv-sandbox])

        user.accredited_hei_provider? && trainee_upload.uploaded?
      end
    end
  end
end
