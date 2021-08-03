# frozen_string_literal: true

module Schools
  class View < GovukComponent::Base
    include SummaryHelper
    include SchoolHelper

    def initialize(data_model:, has_errors: false)
      @data_model = data_model
      @has_errors = has_errors
      @lead_school = trainee.lead_school
      @employing_school = trainee.employing_school
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

  private

    attr_accessor :data_model, :lead_school, :employing_school

    def change_paths(school_type)
      {
        lead: edit_trainee_lead_schools_path(trainee),
        employing: edit_trainee_employing_schools_path(trainee),
      }[school_type.to_sym]
    end
  end
end
