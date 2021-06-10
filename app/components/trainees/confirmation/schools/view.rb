# frozen_string_literal: true

module Trainees
  module Confirmation
    module Schools
      class View < GovukComponent::Base
        include SummaryHelper
        include SchoolHelper

        attr_accessor :data_model, :lead_school, :employing_school

        def initialize(data_model:)
          @data_model = data_model
          @lead_school = trainee.lead_school
          @employing_school = trainee.employing_school
        end

        def trainee
          data_model.is_a?(Trainee) ? data_model : data_model.trainee
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
  end
end
