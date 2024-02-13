# frozen_string_literal: true

module ApiDocs
  class BaseController < ::ApplicationController
    layout "api_docs/pages"
    skip_before_action :authenticate
    before_action { require_feature_flag(:register_api) }
  end
end
