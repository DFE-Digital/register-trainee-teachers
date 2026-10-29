# frozen_string_literal: true

module SystemAdmin
  # Funding management landing page — a hub linking to the funding modules
  # (requirements, uploads, schools management). Gated by funding_management.
  class FundingManagementController < ApplicationController
    before_action { require_feature_flag(:funding_management) }

    def index; end
  end
end
