# frozen_string_literal: true

module Api
  class GuideController < ::ApplicationController
    skip_before_action :authenticate
    before_action { require_feature_flag(:register_api) }

    def show; end
  end
end
