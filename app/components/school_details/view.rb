# frozen_string_literal: true

module SchoolDetails
  class View < GovukComponent::Base
    include SchoolHelper

    attr_reader :trainee, :lead_school, :employing_school

    def initialize(trainee)
      @trainee = trainee
      @lead_school = trainee.lead_school
      @employing_school = trainee.employing_school
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
