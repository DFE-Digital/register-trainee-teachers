# frozen_string_literal: true

class PersonasController < ApplicationController
  def index
    @personas = Persona.all
  end

  def create
    redirect_to action: :index
  end
end
