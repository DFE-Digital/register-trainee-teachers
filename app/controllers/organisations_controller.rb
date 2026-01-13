# frozen_string_literal: true

class OrganisationsController < ApplicationController
  skip_before_action :check_organisation_context_is_set

  def index
    @providers = current_user.providers
    @training_partners = current_user.training_partners.includes(:school, :provider)
  end

  def show
    session[:current_organisation] = { type: params[:type], id: params[:id] }

    redirect_to(session.delete(:requested_path) || root_path)
  end
end
