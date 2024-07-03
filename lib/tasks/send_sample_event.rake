# frozen_string_literal: true

namespace :analytics do
  desc "Send sample events to BigQuery"
  task send_sample_events: :environment do
    event = DfE::Analytics::Event.new
        .with_type("import_entity")
        .with_entity_table_name("trainees")
        .with_data({
          data: [
            { key: "apply_application_id", value: [] },
            { key: "applying_for_bursary", value: ["false"] },
            { key: "applying_for_grant", value: ["false"] },
            { key: "applying_for_scholarship", value: ["false"] },
            { key: "awarded_at", value: [] },
            { key: "bursary_tier", value: [] },
            { key: "trainee_start_date", value: ["2023-08-05"] },
            { key: "commencement_status", value: [] },
            { key: "course_allocation_subject_id", value: [10] },
            { key: "course_education_phase", value: [] },
            { key: "course_max_age", value: [5] },
            { key: "course_min_age", value: [0] },
            { key: "course_subject_one", value: ["early years teaching"] },
            { key: "course_subject_three", value: [] },
            { key: "course_subject_two", value: [] },
            { key: "course_uuid", value: [] },
            { key: "created_at", value: ["2024-04-17T14:13:22.278Z"] },
            { key: "created_from_dttp", value: ["false"] },
            { key: "created_from_hesa", value: ["false"] },
            { key: "defer_date", value: [] },
            { key: "discarded_at", value: [] },
            { key: "diversity_disclosure", value: ["diversity_not_disclosed"] },
            { key: "dormancy_dttp_id", value: [] },
            { key: "dttp_id", value: [] },
            { key: "dttp_update_sha", value: [] },
            { key: "ebacc", value: ["false"] },
            { key: "employing_school_id", value: [] },
            { key: "employing_school_not_applicable", value: ["false"] },
            { key: "end_academic_cycle_id", value: [11] },
            { key: "hesa_id", value: [] },
            { key: "hesa_updated_at", value: [] },
            { key: "id", value: [2] },
            { key: "iqts_country", value: [] },
            { key: "itt_end_date", value: [] },
            { key: "itt_start_date", value: [] },
            { key: "placement_detail", value: [] },
            { key: "lead_school_not_applicable", value: ["false"] },
            { key: "outcome_date", value: [] },
            { key: "placement_assignment_dttp_id", value: [] },
            { key: "provider_id", value: [1] },
            { key: "recommended_for_award_at", value: [] },
            { key: "record_source", value: ["manual"] },
            { key: "region", value: [] },
            { key: "reinstate_date", value: [] },
            { key: "slug", value: ["yDKdMAJmdTCUbyeR3pTGWXKE"] },
            { key: "start_academic_cycle_id", value: [9] },
            { key: "state", value: ["draft"] },
            { key: "study_mode", value: ["part_time"] },
            { key: "submission_ready", value: ["false"] },
            { key: "submitted_for_trn_at", value: [] },
            { key: "training_initiative", value: ["now_teach"] },
            { key: "training_route", value: ["early_years_assessment_only"] },
            { key: "updated_at", value: ["2024-04-17T14:13:22.278Z"] },
            { key: "withdraw_date", value: [] },
            { key: "withdraw_reasons_details", value: [] },
            { key: "withdraw_reasons_dfe_details", value: [] },
            { key: "hesa_trn_submission_id", value: [] },
            { key: "hesa_editable", value: ["false"] },
            { key: "slug_sent_to_dqt_at", value: [] },
            { key: "application_choice_id", value: [] },
          ],
          hidden_data: [
            { key: "disability_disclosure", value: [] },
            { key: "sex", value: ["sex_not_provided"] },
            { key: "lead_school_id", value: [] },
            { key: "progress", value: ['{\"personal_details\":false,\"contact_details\":false,\"degrees\":false,\"placements\":false,\"diversity\":false,\"course_details\":false,\"training_details\":false,\"trainee_start_status\":false,\"trainee_data\":false,\"schools\":false,\"funding\":false,\"iqts_country\":false}\"'] },
            { key: "trn", value: [] },
          ],
        })

    DfE::Analytics::SendEvents.perform_now([event.as_json])
  end
end
