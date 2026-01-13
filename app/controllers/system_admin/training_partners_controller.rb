# frozen_string_literal: true

module SystemAdmin
  class TrainingPartnersController < ApplicationController
    def index
      @training_partners = policy_scope(
        TrainingPartner,
        policy_scope_class: TrainingPartnerPolicy::Scope,
      ).kept.order(:name).page(params[:page] || 1)
    end

    def show
      @training_partner = authorize(TrainingPartner.find(params[:id]))
    end
  end
end
