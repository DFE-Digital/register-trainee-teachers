module Personas
  class View < GovukComponent::Base
    with_collection_parameter :persona

    attr_reader :persona

    def initialize(persona:)
      @persona = persona
    end
  end
end
