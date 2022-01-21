# frozen_string_literal: true

module Personas
  class View < GovukComponent::Base
    include ApplicationHelper
    with_collection_parameter :persona
    attr_reader :persona

    def initialize(persona:)
      @persona = persona
    end

    def association_strings
      providers = persona.providers.map do |provider|
        "Belongs to <strong>#{provider.name}</strong> and is responsible for managing users."
      end
      lead_schools = persona.lead_schools.map do |lead_school|
        "Associated with <strong>#{lead_school.name}</strong> and can view users assigned to that lead school."
      end

      providers + lead_schools
    end
  end
end
