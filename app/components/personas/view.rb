# frozen_string_literal: true

module Personas
  class View < ComponentBase
    include ApplicationHelper
    with_collection_parameter :persona
    attr_reader :persona

    def initialize(persona:)
      @persona = persona
    end

    def association_strings
      providers = persona.providers.map do |provider|
        t("components.personas.view.provider_user", provider_name: provider.name)
      end
      lead_schools = persona.lead_schools.map do |lead_school|
        t("components.personas.view.lead_school_user", lead_school_name: lead_school.name)
      end

      providers + lead_schools
    end
  end
end
