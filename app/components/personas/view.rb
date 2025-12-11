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
      provider_strings + training_partner_strings
    end

  private

    def provider_strings
      @_provider_strings ||= persona.providers.map do |provider|
        t("components.personas.view.provider_user", provider_name: provider.name_and_code)
      end
    end

    def training_partner_strings
      @_training_partner_strings ||= persona.training_partners.map do |training_partner|
        t("components.personas.view.training_partner_user", training_partner_name: training_partner.name)
      end
    end
  end
end
