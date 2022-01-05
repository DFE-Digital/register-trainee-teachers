class OrganisationContextsController < ApplicationController
  skip_before_action :check_organisation_context_is_set

  def index
    redirect_to root_path unless current_user.has_multiple_organisations?

    @providers = current_user.providers
    @lead_schools = current_user.lead_schools
  end

  def show
    # TODO check user has access
    # authorize(organisation) or something like that
    session[:current_organisation] = { type: params[:type], id: params[:id] }

    redirect_to session.delete(:requested_path) || root_path
  end

private

  def organisation
    (params[:type] == "School" ? School : Provider).find_by(id: params[:id])
  end
end
