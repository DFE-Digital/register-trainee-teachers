# frozen_string_literal: true

module Personas
  class View < ViewComponent::Base
    include ApplicationHelper
    with_collection_parameter :persona
    attr_reader :persona

    def initialize(persona:)
      @persona = persona
    end

    def association_strings
      providers + lead_schools + lead_partners
    end

  private

    def providers
      @_providers ||= persona.providers.map do |provider|
        t("components.personas.view.provider_user", provider_name: provider.name)
      end
    end

    def lead_schools
      @_lead_schools ||= persona.lead_schools.map do |lead_school|
        t("components.personas.view.lead_school_user", lead_school_name: lead_school.name)
      end
    end

    def lead_partners
      @_lead_partners ||= persona.lead_partners.map do |lead_partner|
        t("components.personas.view.lead_partner_user", lead_partner_name: lead_partner.name)
      end
    end
  end
end
