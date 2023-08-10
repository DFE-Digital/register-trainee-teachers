# frozen_string_literal: true

module Reports
  class TraineesCsvReport < TemplateClassCsv
    def self.headers
      %w[register_id
         trainee_url
         record_source
         apply_id
         hesa_id
         provider_trainee_id
         trn
         trainee_status
         start_academic_year
         end_academic_year
         academic_years
         record_created_at
         register_record_last_changed_at
         hesa_record_last_changed_at
         submitted_for_trn_at
         provider_name
         provider_id
         first_names
         middle_names
         last_names
         date_of_birth
         sex
         nationality
         address_line_1
         address_line_2
         town_city
         postcode
         international_address
         email_address
         diversity_disclosure
         ethnic_group
         ethnic_background
         ethnic_background_additional
         disability_disclosure
         disabilities
         number_of_degrees
         degree_1_uk_or_non_uk
         degree_1_awarding_institution
         degree_1_country
         degree_1_subject
         degree_1_type_uk
         degree_1_type_non_uk
         degree_1_grade
         degree_1_other_grade
         degree_1_graduation_year
         degrees
         course_training_route
         course_qualification
         course_education_phase
         course_subject_category
         course_itt_subject_1
         course_itt_subject_2
         course_itt_subject_3
         course_minimum_age
         course_maximum_age
         course_full_or_part_time
         course_level
         itt_start_date
         expected_end_date
         course_duration_in_years
         trainee_start_date
         lead_school_name
         lead_school_urn
         employing_school_name
         employing_school_urn
         training_initiative
         funding_method
         funding_value
         bursary_tier
         placement_one
         placement_two
         other_placements
         award_standards_met_date
         award_given_at
         defer_date
         return_from_deferral_date
         withdraw_date
         withdraw_reasons
         withdraw_reasons_details
         withdraw_reasons_dfe_details]
    end

    alias trainees scope

  private

    def add_headers
      csv << self.class.headers
    end

    def add_report_rows
      return csv << ["No trainee data to export"] if trainees.blank? # TODO: move text to translation file

      ::TraineeReport.where(id: trainees.ids).strict_loading.includes({ course_allocation_subject: [:subject_specialisms] },
                                                                      :end_academic_cycle,
                                                                      :start_academic_cycle).in_batches.each_record do |trainee|
        add_trainee_to_csv(trainee)
      end
    end

    def add_trainee_to_csv(trainee)
      csv << trainee.to_csv
    end
  end
end
