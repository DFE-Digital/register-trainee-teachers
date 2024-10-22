# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class ImportRows
      include ServicePattern

      attr_accessor :id

      def initialize(id:)
        self.id = id
      end

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
        "Disability 1" => "disability_1",
        "Disability 2" => "disability_2",
        "Disability 3" => "disability_3",
        "Disability 4" => "disability_4",
        "Disability 5" => "disability_5",
        "Disability 6" => "disability_6",
        "Disability 7" => "disability_7",
        "Disability 8" => "disability_8",
        "Disability 9" => "disability_9",
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
        "Lead Partner URN" => "lead_partner_urn",
        "Employing School URN" => "employing_school_urn",
        "Trainee Start Date" => "trainee_start_date",
        "PG Apprenticeship" => "pg_apprenticeship",
        "Start Date" => "start_date",
        "Fund Code" => "fund_code",
        "Funding Method" => "funding_method",
        "Training Initiative" => "training_initiative",
        "Additional Training Initiative" => "additional_training_initiative",
      }.freeze

      PLACEMENT_HEADERS = {
        "First Placement URN" => "urn",
      }.freeze

      DEGREE_HEADERS = {
        "UK Degree Type" => "uk_degree_type",
        "Non-UK Degree Type" => "non_uk_degree_type",
        "Degree Subject" => "degree_subject",
        "Degree Grade" => "degree_grade",
        "Degree Graduation Year" => "degree_graduation_year",
        "Degree UK" => "degree_uk",
        "Awarding Institution" => "degree_uk",
        "Degree Country" => "degree_country",
      }.freeze

      def call
        return unless FeatureService.enabled?(:bulk_add_trainees)

        success = true
        ActiveRecord::Base.transaction do |_transaction|
          results = CSV.parse(trainee_upload.file, headers: :first_line).map do |row|
            BulkUpdate::AddTrainees::ImportRow.call(row:)
          end

          # Commit or rollback the transaction depending on whether all rows were error free
          if all_succeeded?(results)
            trainee_upload.succeeded!
            true
          else
            # TODO: copy any errors into `trainee_upload`
            success = false
            raise(ActiveRecord::Rollback)
          end
        end

        trainee_upload.failed! unless success
        success
      end

      def trainee_upload
        @trainee_upload ||= BulkUpdate::TraineeUpload.find(id)
      end

    private

      def all_succeeded?(results)
        results.all?
      end
    end
  end
end
