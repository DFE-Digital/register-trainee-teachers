# frozen_string_literal: true

module Trainees
  module Confirmation
    module Schools
      class View < GovukComponent::Base
        include SummaryHelper
        include SchoolHelper

        attr_accessor :data_model

        def initialize(data_model:)
          @data_model = data_model
        end

        def trainee
          data_model.is_a?(Trainee) ? data_model : data_model.trainee
        end

        def lead_school
          @lead_school ||= School.where(id: data_model.lead_school_id).first
        end

        def employing_school
          @employing_school ||= School.where(id: data_model.employing_school_id).first
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
