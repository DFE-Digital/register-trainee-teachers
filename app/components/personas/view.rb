# frozen_string_literal: true

module Personas
  class View < ApplicationComponent
    include ApplicationHelper

    with_collection_parameter :persona
    attr_reader :persona

    def initialize(persona:)
      @persona = persona
    end

    def association_strings
      provider_strings + lead_partner_strings
    end

  private

    def provider_strings
      @_provider_strings ||= persona.providers.map do |provider|
        t("components.personas.view.provider_user", provider_name: provider.name_and_code)
      end
    end

    def lead_partner_strings
      @_lead_partner_strings ||= persona.lead_partners.map do |lead_partner|
        t("components.personas.view.lead_partner_user", lead_partner_name: lead_partner.name)
      end
    end
  end
end
