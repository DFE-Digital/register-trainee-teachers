# frozen_string_literal: true

class OrganisationsController < ApplicationController
  def index
    @providers = current_user.providers
    @lead_schools = current_user.lead_schools
  end
end
