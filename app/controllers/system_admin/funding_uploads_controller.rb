# frozen_string_literal: true

module SystemAdmin
  class FundingUploadsController < ApplicationController
    before_action { require_feature_flag(:funding_uploads) }
    def index; end
  end
end
