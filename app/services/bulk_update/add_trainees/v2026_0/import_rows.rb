# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    module V20260
      class ImportRows < BulkUpdate::AddTrainees::ImportRows
        EMPTY_CSV_TEMPLATE_PATH = "/csv/v2026_0/bulk_create_trainee.csv"

        TRAINEE_HEADERS = {
          "provider_trainee_id" => "provider_trainee_id",
          "application_id" => "application_id",
          "hesa_id" => "hesa_id",
          "first_names" => "first_names",
          "last_name" => "last_name",
          "previous_last_name" => "previous_last_name",
          "date_of_birth" => "date_of_birth",
          "ni_number" => "ni_number",
          "sex" => "sex",
          "email" => "email",
          "nationality" => "nationality",
          "ethnicity" => "ethnicity",
          "disability1" => "disability1",
          "disability2" => "disability2",
          "disability3" => "disability3",
          "disability4" => "disability4",
          "disability5" => "disability5",
          "disability6" => "disability6",
          "disability7" => "disability7",
          "disability8" => "disability8",
          "disability9" => "disability9",
          "itt_aim" => "itt_aim",
          "training_route" => "training_route",
          "itt_qualification_aim" => "itt_qualification_aim",
          "course_subject_1" => "course_subject_1",
          "course_subject_2" => "course_subject_2",
          "course_subject_3" => "course_subject_3",
          "study_mode" => "study_mode",
          "itt_start_date" => "itt_start_date",
          "itt_end_date" => "itt_end_date",
          "course_age_range" => "course_age_range",
          "course_year" => "course_year",
          "training_partner_urn" => "training_partner_urn",
          "employing_school_urn" => "employing_school_urn",
          "trainee_start_date" => "trainee_start_date",
          "pg_apprenticeship_start_date" => "pg_apprenticeship_start_date",
          "fund_code" => "fund_code",
          "funding_method" => "funding_method",
          "training_initiative" => "training_initiative",
          "additional_training_initiative" => "additional_training_initiative",
        }.freeze

        PLACEMENT_HEADERS = {
          "placement_1_urn" => "placement_urn1",
          "placement_2_urn" => "placement_urn2",
          "placement_3_urn" => "placement_urn3",
        }.freeze

        DEGREE_HEADERS = {
          "uk_degree" => "uk_degree",
          "non_uk_degree" => "non_uk_degree",
          "degree_subject" => "subject",
          "degree_grade" => "grade",
          "degree_graduation_year" => "graduation_year",
          "awarding_institution" => "institution",
          "degree_country" => "country",
        }.freeze

        PREFIXED_HEADERS = [
          "hesa_id",
          "date_of_birth",
          "sex",
          "ethnicity",
          "disability1",
          "disability2",
          "disability3",
          "disability4",
          "disability5",
          "disability6",
          "disability7",
          "disability8",
          "disability9",
          "itt_aim",
          "training_route",
          "itt_qualification_aim",
          "course_subject_1",
          "course_subject_2",
          "course_subject_3",
          "study_mode",
          "itt_start_date",
          "itt_end_date",
          "course_age_range",
          "trainee_start_date",
          "pg_apprenticeship_start_date",
          "fund_code",
          "funding_method",
          "training_initiative",
          "additional_training_initiative",
          "uk_degree",
          "non_uk_degree",
          "degree_subject",
          "degree_grade",
          "degree_graduation_year",
          "awarding_institution",
        ].freeze

        ALL_HEADERS = TRAINEE_HEADERS.merge(PLACEMENT_HEADERS).merge(DEGREE_HEADERS)

        CASE_INSENSITIVE_ALL_HEADERS = ALL_HEADERS.to_h { |key, _| [key.downcase, key] }.freeze
      end
    end
  end
end
