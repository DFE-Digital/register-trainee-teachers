# frozen_string_literal: true

module SystemAdmin
  module LeadPartners
    class AccessionsController < ApplicationController
      before_action :load_models

      def edit; end

      def destroy
        @lead_partner.users.delete(@user)
        redirect_to(user_path(@user), flash: { success: "User access removed successfully" })
      end

    private

      def load_models
        @user = authorize(User.find(params[:user_id]))
        @lead_partner = policy_scope(LeadPartner, policy_scope_class: LeadPartnerPolicy::Scope).find(params[:lead_partner_id])
      end
    end
  end
end
