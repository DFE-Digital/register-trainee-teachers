# frozen_string_literal: true

class OrganisationSettingsController < ApplicationController
  def show
    authorize(:organisation_settings)
  end
end
