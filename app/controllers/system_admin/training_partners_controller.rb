# frozen_string_literal: true

module SystemAdmin
  class TrainingPartnersController < ApplicationController
    def index
      @training_partners = policy_scope(
        LeadPartner,
        policy_scope_class: LeadPartnerPolicy::Scope,
      ).kept.order(:name).page(params[:page] || 1)
    end

    def show
      @training_partner = authorize(LeadPartner.find(params[:id]))
    end
  end
end
