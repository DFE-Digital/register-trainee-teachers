# frozen_string_literal: true

module SystemAdmin
  class LeadPartnersController < ApplicationController
    def index
      @lead_partners = LeadPartner.order(:name).page(params[:page] || 1)
    end

    def show
      @lead_partners = authorize(LeadPartner.find(params[:id]), policy_class: LeadPartnerPolicy)
    end
  end
end
