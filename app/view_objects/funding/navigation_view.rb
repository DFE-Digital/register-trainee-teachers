# frozen_string_literal: true

module Funding
  class NavigationView
    include Rails.application.routes.url_helpers

    def initialize(organisation:, system_admin: false)
      @organisation = organisation
      @system_admin = system_admin
    end

    def organisation_name
      @organisation&.name
    end

    def path_for_funding_payment_schedule
      system_admin ? provider_funding_payment_schedule_path(organisation) : funding_payment_schedule_path
    end

    def path_for_funding_trainee_summary
      system_admin ? provider_funding_trainee_summary_path(organisation) : funding_trainee_summary_path
    end

  private

    attr_reader :organisation, :system_admin
  end
end