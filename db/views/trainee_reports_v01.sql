 SELECT trainees.slug                                                                       AS register_id
       -- ruby land
       -- ,'https://www.register-trainee-teachers.service.gov.uk' || ' /trainees/' || trainees.slug AS trainee_url
       ,
       trainees.record_source                                                              AS record_source,
       apply_applications.apply_id                                                         AS apply_id,

       trainees.hesa_id IS NOT NULL                                                        AS hesa_record,
       trainees.apply_application_id IS NOT NULL                                           AS apply_application,
       trainees.created_from_dttp                                                          AS created_from_dttp,

       trainees.hesa_id                                                                    AS hesa_id,
       trainees.trainee_id                                                                 AS provider_trainee_id,
       trainees.trn                                                                        AS trn,
       -- ,'StatusTag::View.new(trainee:).status, trainee.state, trainee.award_type, training_route' AS trainee_status

    --    trainees.award_type                                                                 AS award_type,
       trainees.start_academic_cycle_id                                                    AS start_academic_cycle_id,
       trainees.end_academic_cycle_id                                                      AS end_academic_cycle_id,
       trainees.id                                                                         AS id,
       trainees.state                                                                      AS state,
       trainees.training_route                                                             AS training_route,
       trainees.created_at                                                                 AS created_at,
       trainees.updated_at                                                                 AS updated_at
       ,
       trainees.hesa_updated_at                                                            AS hesa_updated_at,
       trainees.submitted_for_trn_at                                                       AS trainee_submitted_for_trn_at,
       providers.name                                                                      AS provider_name,
       providers.code                                                                      AS provider_id,
       trainees.first_names                                                                AS first_names,
       trainees.middle_names                                                               AS middle_names,
       trainees.last_name                                                                  AS last_names,
       trainees.date_of_birth                                                              AS trainee_date_of_birth,
       trainees.sex                                                                        AS trainee_sex,
       (SELECT Array_agg(nationalities.name)
          FROM nationalities
               INNER JOIN nationalisations
                       ON nationalities.id = nationalisations.nationality_id
         WHERE nationalisations.trainee_id = trainees.id)                                  AS nationality_as_array,
       trainees.address_line_one                                                           AS address_line_1,
       trainees.address_line_two                                                           AS address_line_2,
       trainees.town_city                                                                  AS town_city,
       trainees.postcode                                                                   AS postcode
       --Array(trainee.international_address.to_s.split(/[\r\n,]/)).join(", ").presence
       ,
       trainees.international_address                                                      AS trainee_international_address,
       trainees.email                                                                      AS email_address,
       trainees.diversity_disclosure                                                       AS trainee_diversity_disclosure,
       trainees.ethnic_group                                                               AS trainee_ethnic_group,
       trainees.ethnic_background                                                          AS ethnic_background,
       trainees.additional_ethnic_background                                               AS additional_ethnic_background,
       trainees.disability_disclosure                                                      AS trainee_disability_disclosure,
       (SELECT Array_agg(name)
          FROM (SELECT ( CASE
                           WHEN disabilities.name = 'Other' THEN trainee_disabilities.additional_disability
                           ELSE disabilities.name
                         end ) AS name
                  FROM disabilities
                       INNER JOIN trainee_disabilities
                               ON disabilities.id = trainee_disabilities.disability_id
                 WHERE trainee_disabilities.trainee_id = trainees.id) nested_disabilities) AS disabilities_as_array,
       (SELECT Count(degrees.id)
          FROM degrees
         WHERE degrees.trainee_id = trainees.id)                                           AS number_of_degrees,
       degree_1.uk_or_non_uk                                                               AS degree_1_uk_or_non_uk,
       degree_1.institution                                                                AS degree_1_awarding_institution,
       degree_1.country                                                                    AS degree_1_country,
       degree_1.subject                                                                    AS degree_1_subject,
       degree_1.uk_degree                                                                  AS degree_1_type_uk,
       degree_1.non_uk_degree                                                              AS degree_1_type_non_uk,
       degree_1.grade                                                                      AS degree_1_grade,
       degree_1.other_grade                                                                AS degree_1_other_grade,
       degree_1.graduation_year                                                            AS degree_1_graduation_year,
       (SELECT Jsonb_agg(nested_degrees)
          FROM (SELECT degree_1.uk_or_non_uk AS uk_or_non_uk,
                       degrees.institution,
                       degrees.country,
                       degrees.subject,
                       degrees.uk_degree,
                       degrees.non_uk_degree,
                       degrees.grade,
                       degrees.other_grade,
                       degrees.graduation_year
                  FROM degrees
                 WHERE degrees.trainee_id = trainees.id) AS nested_degrees)                AS degrees_as_json
       -- use trainee.training_route
       -- course_training_route
       -- use trainee.award_type
       -- course_qualification
       -- ruby land
       ,
       trainees.course_education_phase                                                     AS trainee_course_education_phase,
       -- ruby land
       -- course_subject_category

      trainees.course_subject_one                                                          AS course_subject_one,
       trainees.course_subject_one                                                         AS course_itt_subject_1,
       trainees.course_subject_two                                                         AS course_itt_subject_2,
       trainees.course_subject_three                                                       AS course_itt_subject_3,
       trainees.course_min_age                                                             AS course_minimum_age,
       trainees.course_max_age                                                             AS course_maximum_age,
       trainees.study_mode                                                                 AS course_full_or_part_time
       -- ruby land
       -- course_level
       ,
       trainees.itt_start_date                                                             AS trainee_itt_start_date
       -- trainee.itt_end_date.blank? && trainee.hesa_record? && !trainee.awaiting_action?
       -- ruby land awaiting_action
       ,
       trainees.itt_end_date                                                               AS itt_end_date
       -- ruby land
       -- , trainees.course_duration_in_years AS course_duration_in_years
       ,
       trainees.trainee_start_date                                                         AS trainee_trainee_start_date,
       ( CASE
           WHEN trainees.lead_school_not_applicable = false THEN lead_school.name
           ELSE 'Not applicable'
         end )                                                                             AS lead_school_name,
       lead_school.urn                                                                     AS lead_school_urn,
       ( CASE
           WHEN trainees.employing_school_not_applicable = false THEN employing_school.name
           ELSE 'Not applicable'
         end )                                                                             AS employing_school_name,
       employing_school.urn                                                                AS employing_school_urn,
       trainees.training_initiative                                                        AS trainee_training_initiative
       -- ruby land
       -- funding_method
       -- funding_value
       ,
       trainees.bursary_tier                                                               AS trainee_bursary_tier,
       (SELECT CASE schools.urn IS NULL
                 WHEN true THEN placements.name
                 ELSE schools.urn
               end
          FROM placements
               LEFT OUTER JOIN schools
                            ON placements.school_id = schools.id
         WHERE trainees.id = placements.trainee_id
         ORDER BY placements.id ASC
         LIMIT 1)                                                                          AS placement_one,
       (SELECT schools.urn
          FROM placements
               LEFT OUTER JOIN schools
                            ON placements.school_id = schools.id
         WHERE trainees.id = placements.trainee_id
         ORDER BY placements.id ASC
         LIMIT 1 offset 1)                                                                 AS placement_two,
       (SELECT Array_agg(urn)
          FROM (SELECT schools.urn
                  FROM placements
                       LEFT OUTER JOIN schools
                                    ON placements.school_id = schools.id
                 WHERE trainees.id = placements.trainee_id
                 ORDER BY placements.id ASC
                 LIMIT all offset 2) AS nested_other_placements)                           AS other_placements_as_array,
       trainees.outcome_date                                                               AS outcome_date
       -- ruby land
       --  trainee.awarded_at.blank? && trainee.hesa_record? && trainee.awarded?
       -- award_given_at
       ,
       trainees.awarded_at                                                                 AS awarded_at,
       trainees.defer_date                                                                 AS trainee_defer_date,
       trainees.reinstate_date                                                             AS return_from_deferral_date,
       trainees.withdraw_date                                                              AS trainee_withdraw_date,
       (SELECT Array_agg(withdrawal_reasons.name)
          FROM withdrawal_reasons
               INNER JOIN trainee_withdrawal_reasons
                       ON withdrawal_reasons.id = trainee_withdrawal_reasons.withdrawal_reason_id
         WHERE trainee_withdrawal_reasons.trainee_id = trainees.id)                        AS withdraw_reasons_as_array,
       trainees.withdraw_reasons_details                                                   AS withdraw_reasons_details,
       trainees.withdraw_reasons_dfe_details                                               AS withdraw_reasons_dfe_details,
       trainees.course_allocation_subject_id                                               AS course_allocation_subject_id,
       (SELECT Array_agg(name)
          FROM (SELECT subjects.name
                  FROM courses
                       LEFT OUTER JOIN course_subjects
                                    ON courses.id = course_subjects.course_id
                        LEFT OUTER JOIN subjects
                                    ON subjects.id = course_subjects.subject_id
                 WHERE trainees.course_uuid = courses.uuid
                 ORDER BY course_subjects.id
       ) AS nested_course_subjects_names ) AS course_subjects_names_as_array,
       trainees.applying_for_bursary                                                      AS applying_for_bursary,
       trainees.applying_for_grant                                                        AS applying_for_grant,
       trainees.applying_for_scholarship                                                  AS applying_for_scholarship,
       (SELECT courses.level
        FROM courses
        WHERE trainees.course_uuid = courses.uuid)                                        AS course_level_from_courses,
       trainees.reinstate_date                                                            AS reinstate_date
  FROM trainees AS trainees
       LEFT OUTER JOIN apply_applications AS apply_applications
                    ON trainees.apply_application_id = apply_applications.id
       LEFT OUTER JOIN providers AS providers
                    ON trainees.provider_id = providers.id
       LEFT OUTER JOIN (SELECT first_degree.*,
                               ( CASE
                                   WHEN locale_code = 0 THEN 'UK'
                                   ELSE 'non-UK'
                                 end ) AS uk_or_non_uk
                          FROM degrees AS first_degree
                               INNER JOIN (SELECT  Min(id) as id
                                             FROM degrees
                                            GROUP BY trainee_id) AS degrees
                                       ON degrees.id = first_degree.id) AS degree_1
                    ON degree_1.trainee_id = trainees.id
       LEFT OUTER JOIN schools AS lead_school
                    ON trainees.lead_school_id = lead_school.id
       LEFT OUTER JOIN schools AS employing_school
                    ON trainees.employing_school_id = employing_school.id
