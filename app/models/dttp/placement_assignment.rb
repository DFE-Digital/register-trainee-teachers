# frozen_string_literal: true

module Dttp
  class PlacementAssignment < ApplicationRecord
    self.table_name = "dttp_placement_assignments"

    belongs_to :dttp_trainee,
               foreign_key: :contact_dttp_id,
               primary_key: :dttp_id,
               inverse_of: :placement_assignments,
               optional: true,
               class_name: "Dttp::Trainee"

    has_one :dormant_period, foreign_key: :placement_assignment_dttp_id, primary_key: :dttp_id, inverse_of: :placement_assignment

    validates :response, presence: true

    def route_dttp_id
      response["_dfe_routeid_value"]
    end

    def lead_school_id
      response["_dfe_leadschoolid_value"]
    end

    def employing_school_id
      response["_dfe_employingschoolid_value"]
    end

    def study_mode_id
      response["_dfe_studymodeid_value"]
    end

    def funding_id
      response["_dfe_bursarydetailsid_value"]
    end

    def degree_awarding_institution
      response["_dfe_awardinginstitutionid_value"]
    end

    def degree_subject
      response["_dfe_subjectofugdegreeid_value"]
    end

    def degree_type
      response["_dfe_firstdegreeorequivalentid_value"]
    end

    def degree_grade
      response["_dfe_classofugdegreeid_value"]
    end

    def degree_year
      response["dfe_undergraddegreedateobtained"]&.to_date&.year
    end

    def degree_country
      response["_dfe_overseastrainedteachercountryid_value"]
    end
  end
end
