# frozen_string_literal: true

module Dttp
  class DegreeQualification < ApplicationRecord
    self.table_name = "dttp_degree_qualifications"

    belongs_to :dttp_trainee,
               foreign_key: :contact_dttp_id,
               primary_key: :dttp_id,
               optional: true,
               inverse_of: :degree_qualifications,
               class_name: "Dttp::Trainee"

    validates :response, presence: true

    enum state: {
      importable: 0,
      imported: 1,
      non_importable_invalid_data: 2,
    }

    def country_id
      response["_dfe_degreecountryid_value"]
    end

    def end_year
      return if response["dfe_degreeenddate"].blank?

      Date.parse(response["dfe_degreeenddate"]).year
    end

    def institution
      response["_dfe_awardinginstitutionid_value"]
    end

    def degree_type
      response["_dfe_degreetypeid_value"]
    end
  end
end
