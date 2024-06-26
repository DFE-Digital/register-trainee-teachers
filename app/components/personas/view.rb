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
      provider_strings + lead_school_strings + lead_partner_strings
    end

  private

    def provider_strings
      @_provider_strings ||= persona.providers.map do |provider|
        t("components.personas.view.provider_user", provider_name: provider.name)
      end
    end

    def lead_school_strings
      @_lead_school_strings ||= persona.lead_schools.map do |lead_school|
        t("components.personas.view.lead_school_user", lead_school_name: lead_school.name)
      end
    end

    def lead_partner_strings
      @_lead_partner_strings ||= persona.lead_partners.map do |lead_partner|
        t("components.personas.view.lead_partner_user", lead_partner_name: lead_partner.name)
      end
    end
  end
end
