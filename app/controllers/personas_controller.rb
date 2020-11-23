# frozen_string_literal: true

unless FeatureService.enabled?("use_dfe_sign_in")
  class PersonasController < ApplicationController
    def index
      @personas = Persona.all
    end
  end
end
