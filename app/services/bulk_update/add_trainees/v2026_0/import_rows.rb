# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    module V20260
      class ImportRows < BulkUpdate::AddTrainees::ImportRows
        EMPTY_CSV_TEMPLATE_PATH = "/csv/v2026_0/bulk_create_trainee.csv"

        TRAINEE_HEADERS = {
          "Provider Trainee ID" => "provider_trainee_id",
          "Application ID" => "application_id",
          "HESA ID" => "hesa_id",
          "First Names" => "first_names",
          "Last Name" => "last_name",
          "Previous Last Name" => "previous_last_name",
          "Date of Birth" => "date_of_birth",
          "NI Number" => "ni_number",
          "Sex" => "sex",
          "Email" => "email",
          "Nationality" => "nationality",
          "Ethnicity" => "ethnicity",
          "Disability 1" => "disability1",
          "Disability 2" => "disability2",
          "Disability 3" => "disability3",
          "Disability 4" => "disability4",
          "Disability 5" => "disability5",
          "Disability 6" => "disability6",
          "Disability 7" => "disability7",
          "Disability 8" => "disability8",
          "Disability 9" => "disability9",
          "ITT Aim" => "itt_aim",
          "Training Route" => "training_route",
          "Qualification Aim" => "itt_qualification_aim",
          "Course Subject One" => "course_subject_one",
          "Course Subject Two" => "course_subject_two",
          "Course Subject Three" => "course_subject_three",
          "Study Mode" => "study_mode",
          "ITT Start Date" => "itt_start_date",
          "ITT End Date" => "itt_end_date",
          "Course Age Range" => "course_age_range",
          "Course Year" => "course_year",
          "Training Partner URN" => "training_partner_urn",
          "Employing School URN" => "employing_school_urn",
          "Trainee Start Date" => "trainee_start_date",
          "PG Apprenticeship Start Date" => "pg_apprenticeship_start_date",
          "Fund Code" => "fund_code",
          "Funding Method" => "funding_method",
          "Training Initiative" => "training_initiative",
          "Additional Training Initiative" => "additional_training_initiative",
        }.freeze

        PLACEMENT_HEADERS = {
          "Placement 1 URN" => "placement_urn1",
          "Placement 2 URN" => "placement_urn2",
          "Placement 3 URN" => "placement_urn3",
        }.freeze

        DEGREE_HEADERS = {
          "UK Degree Type" => "uk_degree",
          "Non-UK Degree Type" => "non_uk_degree",
          "Degree Subject" => "subject",
          "Degree Grade" => "grade",
          "Degree Graduation Year" => "graduation_year",
          "Awarding Institution" => "institution",
          "Degree Country" => "country",
        }.freeze

        PREFIXED_HEADERS = [
          "HESA ID",
          "Date of Birth",
          "Sex",
          "Ethnicity",
          "Disability 1",
          "Disability 2",
          "Disability 3",
          "Disability 4",
          "Disability 5",
          "Disability 6",
          "Disability 7",
          "Disability 8",
          "Disability 9",
          "ITT Aim",
          "Training Route",
          "Qualification Aim",
          "Course Subject One",
          "Course Subject Two",
          "Course Subject Three",
          "Study Mode",
          "ITT Start Date",
          "ITT End Date",
          "Course Age Range",
          "Trainee Start Date",
          "PG Apprenticeship Start Date",
          "Fund Code",
          "Funding Method",
          "Training Initiative",
          "Additional Training Initiative",
          "UK Degree Type",
          "Non-UK Degree Type",
          "Degree Subject",
          "Degree Grade",
          "Degree Graduation Year",
          "Awarding Institution",
        ].freeze

        ALL_HEADERS = TRAINEE_HEADERS.merge(PLACEMENT_HEADERS).merge(DEGREE_HEADERS)

        CASE_INSENSITIVE_ALL_HEADERS = ALL_HEADERS.to_h { |key, _| [key.downcase, key] }.freeze
      end
    end
  end
end
