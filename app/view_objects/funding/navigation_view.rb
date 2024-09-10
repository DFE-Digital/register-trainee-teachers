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

    def path_for_funding_payment_schedule(year)
      return funding_payment_schedule_path(year) unless system_admin

      provider_funding_payment_schedule_path(provider_id: organisation.id, academic_year: year)
    end

    def path_for_funding_trainee_summary(year)
      return funding_trainee_summary_path(year) unless system_admin

      provider_funding_trainee_summary_path(provider_id: organisation.id, academic_year: year)
    end

  private

    attr_reader :organisation, :system_admin
  end
end
