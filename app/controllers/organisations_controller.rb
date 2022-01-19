# frozen_string_literal: true

class OrganisationsController < ApplicationController
  def index
    @providers = current_user.providers
    @lead_schools = current_user.lead_schools
  end

  def show
    session[:current_organisation] = { type: params[:type], id: params[:id] }

    # redirect_to session.delete(:requested_path) || root_path
    redirect_to(root_path)
  end
end
