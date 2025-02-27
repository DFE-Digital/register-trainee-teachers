# frozen_string_literal: true

module Reports
  class TraineesReport < TemplateClassCsv
    def self.headers
      %w[register_id
         completed
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
         lead_partner_name
         lead_partner_urn
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
         withdrawal_trigger
         withdrawal_future_interest]
    end

    alias trainees scope

  private

    def add_headers
      csv << self.class.headers
    end

    def add_report_rows
      return csv << ["No trainee data to export"] if trainees.blank? # TODO: move text to translation file

      trainees.strict_loading.includes(:apply_application,
                                       { course_allocation_subject: %i[subject_specialisms funding_methods] },
                                       :degrees, :disabilities,
                                       :employing_school,
                                       :end_academic_cycle,
                                       :lead_partner,
                                       { nationalisations: :nationality },
                                       :nationalities,
                                       :provider,
                                       :start_academic_cycle,
                                       :trainee_disabilities,
                                       { placements: :school },
                                       :hesa_students,
                                       :withdrawal_reasons).in_batches.each_record do |trainee|
        add_trainee_to_csv(trainee)
      end
    end

    def add_trainee_to_csv(trainee)
      csv << csv_row(trainee)
    end

    def csv_row(trainee)
      trainee_report = Reports::TraineeReport.new(trainee)
      [
        trainee_report.register_id,
        trainee_report.completed,
        trainee_report.trainee_url,
        trainee_report.record_source,
        trainee_report.apply_id,
        trainee_report.hesa_id,
        trainee_report.provider_trainee_id,
        trainee_report.trn,
        trainee_report.trainee_status,
        trainee_report.start_academic_year,
        trainee_report.end_academic_year,
        trainee_report.academic_years,
        trainee_report.record_created_at,
        trainee_report.register_record_last_changed_at,
        trainee_report.hesa_record_last_changed_at,
        trainee_report.submitted_for_trn_at,
        trainee_report.provider_name,
        trainee_report.provider_id,
        trainee_report.first_names,
        trainee_report.middle_names,
        trainee_report.last_names,
        trainee_report.date_of_birth,
        trainee_report.sex,
        trainee_report.nationality,
        trainee_report.email_address,
        trainee_report.diversity_disclosure,
        trainee_report.ethnic_group,
        trainee_report.ethnic_background,
        trainee_report.ethnic_background_additional,
        trainee_report.disability_disclosure,
        trainee_report.disabilities,
        trainee_report.number_of_degrees,
        trainee_report.degree_1_uk_or_non_uk,
        trainee_report.degree_1_awarding_institution,
        trainee_report.degree_1_country,
        trainee_report.degree_1_subject,
        trainee_report.degree_1_type_uk,
        trainee_report.degree_1_type_non_uk,
        trainee_report.degree_1_grade,
        trainee_report.degree_1_other_grade,
        trainee_report.degree_1_graduation_year,
        trainee_report.degrees,
        trainee_report.course_training_route,
        trainee_report.course_qualification,
        trainee_report.course_education_phase,
        trainee_report.course_subject_category,
        trainee_report.course_itt_subject_1,
        trainee_report.course_itt_subject_2,
        trainee_report.course_itt_subject_3,
        trainee_report.course_minimum_age,
        trainee_report.course_maximum_age,
        trainee_report.course_full_or_part_time,
        trainee_report.course_level,
        trainee_report.itt_start_date,
        trainee_report.expected_end_date,
        trainee_report.course_duration_in_years,
        trainee_report.trainee_start_date,
        trainee_report.lead_partner_name,
        trainee_report.lead_partner_urn,
        trainee_report.employing_school_name,
        trainee_report.employing_school_urn,
        trainee_report.training_initiative,
        trainee_report.funding_method,
        trainee_report.funding_value,
        trainee_report.bursary_tier,
        trainee_report.placement_one,
        trainee_report.placement_two,
        trainee_report.other_placements,
        trainee_report.award_standards_met_date,
        trainee_report.award_given_at,
        trainee_report.defer_date,
        trainee_report.return_from_deferral_date,
        trainee_report.withdraw_date,
        trainee_report.withdraw_reasons,
        trainee_report.withdrawal_trigger,
        trainee_report.withdrawal_future_interest,
      ].map { |value| CsvValueSanitiser.new(value).sanitise }
    end
  end
end
