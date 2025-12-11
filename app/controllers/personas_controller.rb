# frozen_string_literal: true

class PersonasController < ApplicationController
  skip_before_action :authenticate

  def index
    @personas = Persona.includes(:providers, :training_partners).order(:first_name)
  end
end
