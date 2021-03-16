# frozen_string_literal: true

module Personas
  class View < GovukComponent::Base
    include ApplicationHelper
    with_collection_parameter :persona
    attr_reader :persona

    def initialize(persona:)
      @persona = persona
    end
  end
end
