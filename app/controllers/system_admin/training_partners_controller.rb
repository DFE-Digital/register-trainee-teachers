# frozen_string_literal: true

module SystemAdmin
  class TrainingPartnersController < ApplicationController
    def index
      @lead_partners = policy_scope(
        LeadPartner,
        policy_scope_class: LeadPartnerPolicy::Scope,
      ).kept.order(:name).page(params[:page] || 1)
    end

    def show
      @lead_partner = authorize(LeadPartner.find(params[:id]))
    end
  end
end
