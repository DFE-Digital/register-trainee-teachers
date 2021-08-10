# frozen_string_literal: true

unless FeatureService.enabled?("use_dfe_sign_in")
  class PersonasController < ApplicationController
    skip_before_action :authenticate
    def index
      @personas = Persona.all.order(:first_name)
    end
  end
end
