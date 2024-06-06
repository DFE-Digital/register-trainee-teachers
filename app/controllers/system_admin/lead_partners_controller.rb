# frozen_string_literal: true

module SystemAdmin
  class LeadPartnersController < ApplicationController
    before_action { require_feature_flag(:lead_partners) }

    def index
      @lead_partners = LeadPartner.order(:name).page(params[:page] || 1)
    end

    def show
      @lead_partner = authorize(LeadPartner.find(params[:id]))
    end
  end
end
