# frozen_string_literal: true

module SchoolDetails
  class View < GovukComponent::Base
    include SchoolHelper

    attr_reader :trainee, :lead_school, :employing_school, :has_errors, :system_admin

    def initialize(trainee, has_errors: false, system_admin: false)
      @trainee = trainee
      @lead_school = trainee.lead_school
      @employing_school = trainee.employing_school
      @has_errors = has_errors
      @system_admin = system_admin
    end

    def school_rows
      [
        lead_school_row(not_applicable: trainee.lead_school_not_applicable?),
        employing_school_row(not_applicable: trainee.employing_school_not_applicable?),
      ].compact
    end

  private

    def change_paths(school_type)
      {
        lead: edit_trainee_lead_schools_path(trainee),
        employing: edit_trainee_employing_schools_path(trainee),
      }[school_type.to_sym]
    end
  end
end
