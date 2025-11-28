# frozen_string_literal: true

module SystemAdmin
  class UserTrainingPartnersController < ApplicationController
    before_action :set_user
    helper_method :query

    def index
      @training_partner_form = UserTrainingPartnersForm.new
      @training_partner_search = TrainingPartnerSearch.call(query:)
    end

    def new
      @training_partner_form = UserTrainingPartnersForm.new
    end

    def create
      @training_partner_form = UserTrainingPartnersForm.new(training_partner_params.merge(user: @user))

      if @training_partner_form.partner_not_selected? && @training_partner_form.valid?
        return redirect_to(user_training_partners_path(query:))
      end

      if @training_partner_form.save
        redirect_to(user_path(@user), flash: { success: "Training partner added" })
      else
        @training_partner_search = TrainingPartnerSearch.call(query: params[:query])
        render(index_or_new_page)
      end
    end

  private

    def training_partner_params
      params.fetch(:system_admin_user_training_partners_form, {})
            .permit(UserTrainingPartnersForm::FIELDS)
    end

    def set_user
      @user = User.find(params[:user_id])
    end

    def query
      training_partner_params[:results_search_again_query].presence ||
        training_partner_params[:no_results_search_again_query] || training_partner_params[:query] ||
        params[:query]
    end

    def index_or_new_page
      @training_partner_form.search_results_found? || @training_partner_form.no_results_searching_again? ? :index : :new
    end
  end
end
