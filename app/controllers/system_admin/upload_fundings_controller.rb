# frozen_string_literal: true

module SystemAdmin
  class UploadFundingsController < ApplicationController
    before_action { require_feature_flag(:upload_funding) }
    def index; end
  end
end
