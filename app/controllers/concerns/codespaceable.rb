# frozen_string_literal: true

module Codespaceable
  extend ActiveSupport::Concern

  GITHUB_APP_DOMAIN = "app.github.dev".freeze

  included do
    skip_before_action :verify_authenticity_token, if: :running_in_codespace?
  end

  private

    def running_in_codespace?
      Rails.env.development? && request.host.contains?(GITHUB_APP_DOMAIN)
    end
end
