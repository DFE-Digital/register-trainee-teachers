# frozen_string_literal: true

module SchoolDetails
  class View < ApplicationComponent
    include SchoolHelper
    include LeadPartnerHelper

    attr_reader :trainee, :lead_partner, :employing_school, :has_errors, :editable

    def initialize(trainee:, has_errors: false, editable: false)
      @trainee = trainee
      @lead_partner = trainee.lead_partner
      @employing_school = trainee.employing_school
      @has_errors = has_errors
      @editable = editable
    end

    def school_rows
      [
        lead_partner_row(not_applicable: trainee.lead_partner_not_applicable?),
        employing_school_row(not_applicable: trainee.employing_school_not_applicable?),
      ].compact
    end

  private

    def change_paths(school_type)
      {
        lead: edit_trainee_lead_partners_path(trainee),
        employing: edit_trainee_employing_schools_path(trainee),
      }[school_type.to_sym]
    end
  end
end
