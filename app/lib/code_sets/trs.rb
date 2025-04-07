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
      "assessment_only" => "AssessmentOnlyRoute",
      "provider_led_postgrad" => "ProviderLedPostgrad",
      "provider_led_undergrad" => "ProviderLedUndergrad",
      "school_direct" => "SchoolDirect",
      "school_direct_salaried" => "SchoolDirectSalaried",
      "teach_first" => "TeachFirst",
      "iqts" => "InternationalQualifiedTeacherStatus",
    }.freeze

    DEGREE_TYPES = {
      "BA" => "BA",
      "BA (Hons)" => "BAHons",
      "BEd" => "BEd",
      "BEd (Hons)" => "BEdHons",
      "BSc" => "BSc",
      "BSc (Hons)" => "BScHons",
      "Postgraduate Certificate in Education" => "PostgraduateCertificateInEducation",
      "Postgraduate Diploma in Education" => "PostgraduateDiplomaInEducation",
      "Undergraduate Master of Teaching" => "UndergraduateMasterOfTeaching",
      "Professional Graduate Certificate in Education" => "ProfessionalGraduateCertificateInEducation",
      "Masters, not by research" => "MastersNotByResearch",
    }.freeze

    ROUTE_STATUSES = {
      "withdrawn" => "Withdrawn",
      "deferred" => "Deferred",
      "awarded" => "Pass",
      "recommended_for_award" => "Recommended",
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
