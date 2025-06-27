# frozen_string_literal: true

class ServiceUpdatesController < ApplicationController
  skip_before_action :authenticate

  def index
    @service_updates = ServiceUpdate.all
  end

  def show
    @service_update = ServiceUpdate.find_by_id(params[:id])
    raise(ActionController::RoutingError, "Not Found") if @service_update.nil?
  end
end
