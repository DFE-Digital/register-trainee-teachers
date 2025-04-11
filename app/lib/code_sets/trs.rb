# frozen_string_literal: true

module CodeSets
  module Trs
    GENDER_CODES = {
      male: "Male",
      female: "Female",
      other: "Other",
      prefer_not_to_say: "NotProvided",
      sex_not_provided: "NotAvailable",
    }.freeze

    # States in which trainee updates are NOT valid
    INVALID_UPDATE_STATES = %w[
      withdrawn
      awarded
    ].freeze

    ROUTE_TYPES = {
      "assessment_only" => "57b86cef-98e2-4962-a74a-d47c7a34b838", # Assessment Only Route
      "provider_led_postgrad" => "97497716-5ac5-49aa-a444-27fa3e2c152a", # Provider led Postgrad
      "provider_led_undergrad" => "53a7fbda-25fd-4482-9881-5cf65053888d", # Provider led Undergrad
      "school_direct" => "d9490e58-acdc-4a38-b13e-5a5c21417737", # School Direct Training Programme
      "school_direct_salaried" => "12a742c3-1cd4-43b7-a2fa-1000bd4cc373", # School Direct Training Programme Salaried
      "teach_first" => "5b7f5e90-1ca6-4529-baa0-dfba68e698b8", # Teach First Programme
      "iqts" => "d0b60864-ab1c-4d49-a5c2-ff4bd9872ee1", # International Qualified Teacher Status
    }.freeze

    DEGREE_TYPES = {
      "BA" => "969c89e7-35b8-43d8-be07-17ef76c3b4bf", # BA
      "BA (Hons)" => "dbb7c27b-8a27-4a94-908d-4b4404acebd5", # BA (Hons)
      "BEd" => "b7b0635a-22c3-41e3-a420-77b9b58c51cd", # BEd
      "BEd (Hons)" => "9b35bdfa-cbd5-44fd-a45a-6167e7559de7", # BEd (Hons)
      "BSc" => "35d04fbb-c19b-4cd9-8fa6-39d90883a52a", # BSc
      "BSc (Hons)" => "9959e914-f4f4-44cd-909f-e170a0f1ac42", # BSc (Hons)
      "Postgraduate Certificate in Education" => "40a85dd0-8512-438e-8040-649d7d677d07", # Postgraduate Certificate in Education
      "Postgraduate Diploma in Education" => "63d80489-ee3d-43af-8c4a-1d6ae0d65f68", # Postgraduate Diploma in Education
      "Undergraduate Master of Teaching" => "dba69141-4101-4e05-80e0-524e3967d589", # Undergraduate Master of Teaching
      "Professional Graduate Certificate in Education" => "d8e267d2-ed85-4eee-8119-45d0c6cc5f6b", # Professional Graduate Certificate in Education
      "Masters, not by research" => "9cf31754-5ac5-46a1-99e5-5c98cba1b881", # Unknown (using Unknown as fallback)
    }.freeze

    ROUTE_STATUSES = {
      "withdrawn" => "Withdrawn",
      "deferred" => "Deferred",
      "awarded" => "Awarded", # Changed from "Pass" to "Awarded" to match TRS statuses
      "recommended_for_award" => "Approved", # Changed from "Recommended" to "Approved" to match TRS statuses
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
