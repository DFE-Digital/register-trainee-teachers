# frozen_string_literal: true

module Dttp
  class Trainee < ApplicationRecord
    self.table_name = "dttp_trainees"

    ACADEMIC_YEAR_ENTITY_IDS = Dttp::CodeSets::AcademicYears::MAPPING.values.map { |x| x[:entity_id] }.reverse

    PLACEMENT_ASSIGNMENTS_ORDER_SQL = sanitize_sql_array(["array_position(ARRAY[?]::uuid[], academic_year::uuid)", ACADEMIC_YEAR_ENTITY_IDS])

    has_many :placement_assignments, -> { order(Arel.sql("#{PLACEMENT_ASSIGNMENTS_ORDER_SQL}, response->'modifiedon' DESC")) },
             foreign_key: :contact_dttp_id,
             primary_key: :dttp_id,
             inverse_of: :dttp_trainee,
             class_name: "Dttp::PlacementAssignment"

    has_one :latest_placement_assignment, -> { order(Arel.sql("#{PLACEMENT_ASSIGNMENTS_ORDER_SQL}, response->'modifiedon' DESC")) },
            foreign_key: :contact_dttp_id,
            primary_key: :dttp_id,
            inverse_of: :dttp_trainee,
            class_name: "Dttp::PlacementAssignment"

    has_many :degree_qualifications,
             foreign_key: :contact_dttp_id,
             primary_key: :dttp_id,
             inverse_of: :dttp_trainee,
             class_name: "Dttp::DegreeQualification"

    belongs_to :trainee,
               foreign_key: :dttp_id,
               primary_key: :dttp_id,
               inverse_of: :dttp_trainee,
               optional: true,
               class_name: "::Trainee"

    belongs_to :provider,
               foreign_key: :provider_dttp_id,
               primary_key: :dttp_id,
               inverse_of: :dttp_trainees,
               optional: true,
               class_name: "::Provider"

    validates :response, presence: true

    enum state: {
      importable: 0,
      imported: 1,
      non_importable_duplicate: 2,
      non_importable_missing_route: 3,
      non_importable_hpitt: 4,
      non_importable_missing_state: 5,
      non_importable_multi_provider: 6,
      non_importable_multi_course: 7,
      non_importable_missing_funding: 8,
      non_importable_missing_initiative: 9,
    }

    def hesa_id
      response["dfe_husid"]
    end

    def created_at
      response["createdon"]
    end

    def updated_at
      response["modifiedon"]
    end

    def date_of_birth
      return if response["birthdate"].blank?

      Date.parse(response["birthdate"])
    end

    def ethnicity
      response["_dfe_ethnicityid_value"]
    end

    def gender_code
      response["gendercode"]
    end

    def nationality
      response["_dfe_nationality_value"]
    end

    def trn
      response["dfe_trn"]&.strip
    end

    def country
      response["address1_country"]
    end

    def postcode
      response["address1_postalcode"]
    end

    def earliest_placement_assignment
      @earliest_placement_assignment ||= placement_assignments.last
    end
  end
end
