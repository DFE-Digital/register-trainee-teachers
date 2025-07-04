# frozen_string_literal: true

module CodeSets
  module Trs
    GENDER_CODES = {
      male: "Male",
      female: "Female",
      other: "Other",
      prefer_not_to_say: "Other",
      sex_not_provided: "Other",
    }.freeze

    # States in which trainee updates are NOT valid
    INVALID_UPDATE_STATES = %w[
      withdrawn
      awarded
    ].freeze

    ROUTE_TYPES = {
      "assessment_only" => "57b86cef-98e2-4962-a74a-d47c7a34b838",
      "early_years_assessment_only" => "d9eef3f8-fde6-4a3f-a361-f6655a42fa1e",
      "early_years_postgrad" => "dbc4125b-9235-41e4-abd2-baabbf63f829",
      "early_years_salaried" => "4477e45d-c531-4c63-9f4b-e157766366fb",
      "early_years_undergrad" => "c97c0fd2-fd84-4949-97c7-b0e2422fb3c8",
      "hpitt_postgrad" => "bfef20b2-5ac4-486d-9493-e5a4538e1be9",
      "iqts" => "d0b60864-ab1c-4d49-a5c2-ff4bd9872ee1",
      "opt_in_undergrad" => "20f67e38-f117-4b42-bbfc-5812aa717b94",
      "pg_teaching_apprenticeship" => "6987240e-966e-485f-b300-23b54937fb3a",
      "provider_led_postgrad" => "97497716-5ac5-49aa-a444-27fa3e2c152a",
      "provider_led_undergrad" => "53a7fbda-25fd-4482-9881-5cf65053888d",
      "school_direct_salaried" => "12a742c3-1cd4-43b7-a2fa-1000bd4cc373",
      "school_direct_tuition_fee" => "d9490e58-acdc-4a38-b13e-5a5c21417737",
      "teach_first" => "5b7f5e90-1ca6-4529-baa0-dfba68e698b8",
    }.freeze

    DEGREE_TYPES = {
      "BA" => "969c89e7-35b8-43d8-be07-17ef76c3b4bf",
      "BA (Hons)" => "dbb7c27b-8a27-4a94-908d-4b4404acebd5",
      "BEd" => "b7b0635a-22c3-41e3-a420-77b9b58c51cd",
      "BEd (Hons)" => "9b35bdfa-cbd5-44fd-a45a-6167e7559de7",
      "BSc" => "35d04fbb-c19b-4cd9-8fa6-39d90883a52a",
      "BSc (Hons)" => "9959e914-f4f4-44cd-909f-e170a0f1ac42",
      "Postgraduate Certificate in Education" => "40a85dd0-8512-438e-8040-649d7d677d07",
      "Postgraduate Diploma in Education" => "63d80489-ee3d-43af-8c4a-1d6ae0d65f68",
      "Undergraduate Master of Teaching" => "dba69141-4101-4e05-80e0-524e3967d589",
      "Professional Graduate Certificate in Education" => "d8e267d2-ed85-4eee-8119-45d0c6cc5f6b",
      "Masters, not by research" => "9cf31754-5ac5-46a1-99e5-5c98cba1b881",
      "Unknown" => "9cf31754-5ac5-46a1-99e5-5c98cba1b881",
    }.freeze

    ROUTE_STATUSES = {
      "withdrawn" => "Withdrawn",
      "deferred" => "Deferred",
      "awarded" => "Holds",
      "recommended_for_award" => "Holds",
    }.freeze

    # Special case statuses based on state and route
    def self.training_status(state, route)
      return ROUTE_STATUSES[state] if ROUTE_STATUSES.key?(state)

      if %w[trn_received submitted_for_trn].include?(state)
        route == "assessment_only" ? "UnderAssessment" : "InTraining"
      end
    end

    # Check if a trainee's state is valid for updates
    def self.valid_for_update?(state)
      !INVALID_UPDATE_STATES.include?(state)
    end
  end
end
