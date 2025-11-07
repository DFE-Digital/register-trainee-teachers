---
title: POST /trainees/{trainee_id}/withdraw
weight: 13
---

# `POST /trainees/{trainee_id}/withdraw`

Withdraw a trainee.

## Request

    POST /api/v2025.0/trainees/{trainee_id}/withdraw

## Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |

## Request body

Withdraw details

<div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
  <dt class="govuk-summary-list__key"><code>trigger</code></dt>
  <dd class="govuk-summary-list__value">
    <p class="govuk-body">
      string, required
    </p>
    <p class="govuk-body">
      The party who initiated the withdrawal. Must be either <code>provider</code> or <code>trainee</code>.
    </p>
    <p class="govuk-body">
      Example: <code>provider</code>
    </p>
  </dd>
</div>
<div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
  <dt class="govuk-summary-list__key"><code>future_interest</code></dt>
  <dd class="govuk-summary-list__value">
    <p class="govuk-body">
      string, required
    </p>
    <p class="govuk-body">
      Whether the trainee would be interested in resuming training in the future. Must be either <code>yes</code>, <code>no</code> or <code>unknown</code>.
    </p>
    <p class="govuk-body">
      Example: <code>no</code>
    </p>
  </dd>
  </div>
<div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
  <dt class="govuk-summary-list__key"><code>withdraw_date</code></dt>
  <dd class="govuk-summary-list__value">
    <p class="govuk-body">
      string, required
    </p>
    <p class="govuk-body">
      The date that the trainee is withdrawing from the course.
    </p>
    <p class="govuk-body">
      Example: <code>2025-02-03</code>
    </p>
  </dd>
  </div>
<div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
  <dt class="govuk-summary-list__key"><code>reasons</code></dt>
  <dd class="govuk-summary-list__value">
    <p class="govuk-body">
      array, required
    </p>
    <p class="govuk-body">
      The reason(s) for the withdrawal. Valid values with trigger <code>trainee</code> are <code>unacceptable_behaviour</code>, <code>did_not_make_progress</code>, <code>lack_of_progress_during_placements</code>, <code>trainee_workload_issues</code>, <code>not_meeting_qts_standards</code>, <code>change_in_personal_or_health_circumstances</code>, <code>does_not_want_to_become_a_teacher</code>, <code>never_intended_to_obtain_qts</code>, <code>moved_to_different_itt_course</code>, <code>trainee_chose_to_withdraw_another_reason</code>, <code>safeguarding_concerns</code>.
      Valid values with trigger <code>provider</code> are <code>record_added_in_error</code>, <code>mandatory_reasons</code>, <code>stopped_responding_to_messages</code>, <code>unacceptable_behaviour</code>, <code>lack_of_progress_during_placements</code>, <code>did_not_make_progress</code>, <code>not_meeting_qts_standards</code>, <code>had_to_withdraw_trainee_another_reason</code>, <code>safeguarding_concerns</code>.
    </p>
    <p class="govuk-body">
      Example: <code>[`unacceptable_behaviour`]</code>
    </p>
  </dd>
</div>
<div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
  <dt class="govuk-summary-list__key"><code>another_reason</code></dt>
  <dd class="govuk-summary-list__value">
    <p class="govuk-body">
      string, conditional
    </p>
    <p class="govuk-body">
       The reason a trainee withdrew if the other values do not sufficiently describe why the trainee withdrew. Required if <code>reasons</code> include <code>trainee_chose_to_withdraw_another_reason</code> or <code>had_to_withdraw_trainee_another_reason</code>.
    </p>
    <p class="govuk-body">
      Example: <code>Bespoke reason</code>
    </p>
  </dd>
</div>
<div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
  <dt class="govuk-summary-list__key"><code>safeguarding_concern_reasons</code></dt>
  <dd class="govuk-summary-list__value">
    <p class="govuk-body">
      string, conditional
    </p>
    <p class="govuk-body">
       More information about the safeguarding concern that caused a trainee to be withdrawn. Required if <code>reasons</code> is <code>safeguarding_concerns</code>.
    </p>
    <p class="govuk-body">
      Example: <code>Detail about the safeguarding concerns</code>
    </p>
  </dd>
</div>

<details class="govuk-details">
  <summary class="govuk-details__summary">Example request body</summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": {
        "trigger": "provider,
        "future_interest": "no",
        "withdraw_date": "2025-03-05",
        "reasons": [
          "unacceptable_behavior",
          "had_to_withdraw_trainee_another_reason",
          "safeguarding_concerns"
        ],
        "another_reason": "Bespoke reason",
        "safeguarding_concern_reasons": "Reasons for safeguarding concern"
      }
    }</pre>
  </div>
</details>

## Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 200<span> - A trainee</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": {
        "trainee_id": "vcGjpBCn987jJSqMQxjhdv9Y",
        "provider_trainee_id": "abc1234",
        "first_names": "Trainee",
        "last_name": "TraineeUser644065",
        "date_of_birth": "2000-01-01",
        "created_at": "2023-10-20T14:54:47.374Z",
        "updated_at": "2024-01-24T16:03:28.721Z",
        "email": "trainee_644065@example.com",
        "middle_names": null,
        "training_route": "11",
        "sex": "10",
        "diversity_disclosure": "diversity_disclosed",
        "ethnic_group": "black_ethnic_group",
        "ethnic_background": "African",
        "additional_ethnic_background": null,
        "disability_disclosure": "no_disability",
        "course_subject_one": "100425",
        "itt_start_date": "2023-09-04",
        "outcome_date": null,
        "itt_end_date": "2023-10-17",
        "trn": "6440650",
        "submitted_for_trn_at": "2024-01-18T08:02:41.420Z",
        "state": "deferred",
        "withdraw_date": null,
        "defer_date": "2023-10-17",
        "defer_reason": null,
        "recommended_for_award_at": null,
        "trainee_start_date": "2023-09-04",
        "reinstate_date": null,
        "course_min_age": 5,
        "course_max_age": 11,
        "course_subject_two": null,
        "course_subject_three": null,
        "awarded_at": null,
        "training_initiative": "009",
        "applying_for_bursary": false,
        "bursary_tier": null,
        "study_mode": "01",
        "ebacc": false,
        "region": null,
        "applying_for_scholarship": false,
        "course_education_phase": "primary",
        "applying_for_grant": false,
        "course_uuid": null,
        "lead_partner_not_applicable": false,
        "employing_school_not_applicable": false,
        "submission_ready": true,
        "commencement_status": null,
        "discarded_at": null,
        "created_from_dttp": false,
        "hesa_id": "87960005710008762",
        "additional_dttp_data": null,
        "created_from_hesa": false,
        "hesa_updated_at": null
        "record_source": "api",
        "iqts_country": null,
        "hesa_editable": true,
        "withdrawal_future_interest": null,
        "withdrawal_trigger": null,
        "withdrawal_reasons": null,
        "placement_detail": null,
        "ukprn": "10000571",
        "ethnicity": "120",
        "course_qualification": "QTS",
        "course_title": null,
        "course_level": "undergrad",
        "course_itt_start_date": "2022-09-01",
        "course_age_range": null,
        "employing_school_urn": null,
        "lead_partner_ukprn": null,
        "lead_partner_urn": null,
        "fund_code": "7",
        "bursary_level": "4",
        "course_year": "2",
        "funding_method": "4",
        "itt_aim": "201",
        "itt_qualification_aim": "004",
        "ni_number": null,
        "previous_last_name": null,
        "hesa_disabilities": null,
        "additional_training_initiative": null,
        "placements": [
          {
            "placement_id": "AXsRAS4LfwZZXvSX7aAfNUb4",
            "urn": "123456",
            "name": "Meadow Creek School",
            "address": "URN 123456, AB1 2CD",
            "postcode": "AB1 2CD",
            "created_at": "2024-01-18T08:02:42.672Z",
            "updated_at": "2024-01-18T08:02:42.672Z"
          }
        ],
        "degrees": [
          {
            "degree_id": "E1phsAcP3hDFMhx19qVGhchR",
            "uk_degree": "083",
            "non_uk_degree": null,
            "created_at": "2024-01-18T08:02:41.955Z",
            "updated_at": "2024-01-18T08:02:41.955Z",
            "subject": "100425",
            "institution": "0116",
            "graduation_year": 2022,
            "grade": "02",
            "country": null,
            "other_grade": null,
            "institution_uuid": "0271f34a-2887-e711-80d8-005056ac45bb",
            "uk_degree_uuid": "db695652-c197-e711-80d8-005056ac45bb",
            "subject_uuid": "bf8170f0-5dce-e911-a985-000d3ab79618",
            "grade_uuid": "e2fe18d4-8655-47cf-ab1a-8c3e0b0f078f"
          }
        ]
      }
    }</pre>
  </div>
</details>

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 401<span> - Unauthorized</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "error": "Unauthorized"
    }</pre>
  </div>
</details>

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 404<span> - Not found</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "errors": [
        {
          "error": "NotFound",
          "message": "Trainee(s) not found"
        }
      ]
    }</pre>
  </div>
</details>

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 422<span> - Unprocessable Entity</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "errors": [
        {
          "error": "UnprocessableEntity",
          "message": "Withdraw date Choose a withdrawal date"
        }
      ]
    }</pre>
  </div>
</details>
