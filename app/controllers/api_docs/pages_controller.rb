# frozen_string_literal: true

module ApiDocs
  class PagesController < ::ApplicationController
    layout "api_docs/pages"
    skip_before_action :authenticate
    before_action { require_feature_flag(:register_api) }

    def home; end

    def release_notes; end

    def reference; end
  end
end
