class PersonasController < ApplicationController
  def index
    @personas = Persona.all
  end
end
