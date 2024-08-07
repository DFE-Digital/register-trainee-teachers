# frozen_string_literal: true

class PersonasController < ApplicationController
  skip_before_action :authenticate

  def index
    @personas = Persona.includes(:providers, :lead_partners).order(:first_name)
  end
end
