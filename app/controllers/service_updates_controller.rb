# frozen_string_literal: true

class ServiceUpdatesController < ApplicationController
  skip_before_action :authenticate

  def index
    @service_updates = ServiceUpdate.all
  end
end
