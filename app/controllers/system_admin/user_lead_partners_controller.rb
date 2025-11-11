# frozen_string_literal: true

module SystemAdmin
  class UserLeadPartnersController < ApplicationController
    before_action :set_user
    helper_method :query

    def index
      @lead_partner_form = UserLeadPartnersForm.new
      @lead_partner_search = LeadPartnerSearch.call(query:)
    end

    def new
      @lead_partner_form = UserLeadPartnersForm.new
    end

    def create
      @lead_partner_form = UserLeadPartnersForm.new(lead_partner_params.merge(user: @user))

      if @lead_partner_form.partner_not_selected? && @lead_partner_form.valid?
        return redirect_to(user_lead_partners_path(query:))
      end

      if @lead_partner_form.save
        redirect_to(user_path(@user), flash: { success: "Training partner added" })
      else
        @lead_partner_search = LeadPartnerSearch.call(query: params[:query])
        render(index_or_new_page)
      end
    end

  private

    def lead_partner_params
      params.fetch(:system_admin_user_lead_partners_form, {})
            .permit(UserLeadPartnersForm::FIELDS)
    end

    def set_user
      @user = User.find(params[:user_id])
    end

    def query
      lead_partner_params[:results_search_again_query].presence || lead_partner_params[:no_results_search_again_query] || lead_partner_params[:query] || params[:query]
    end

    def index_or_new_page
      @lead_partner_form.search_results_found? || @lead_partner_form.no_results_searching_again? ? :index : :new
    end
  end
end
