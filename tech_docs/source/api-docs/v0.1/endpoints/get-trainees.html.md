---
title: GET /trainees
weight: 2
---

# `GET /trainees`

Get many trainees.

Note that this endpoint always returns the trainees for a single academic
cycle. If no academic cycle parameter is specified we return trainees in the
current academic cycle.

## Request

`GET /api/v0.1/trainees`

## Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **academic_cycle** | query | string | false | The academic cycle year (default is the current academic cycle). |
| **status** | query | string | false | Include only trainees with a particular status. Valid values are `course_not_yet_started`, `in_training`,  `deferred`, `awarded`,  `withdrawn` |
| **since** | query | string | false | Include only trainees changed or created on or since a date and time. DateTimes should be in ISO 8601 format. |
| **has_trn** | query | boolean | false | Include only trainees with or without a `trn` |
| **page** | query | integer | false | Page number (defaults to 1, the first page). |
| **per_page** | query | integer | false | Number of records to return per page (default is 50) |
| **sort_order** | query | string | false | Sort in ascending or descending order. Valid values are `asc` or `desc` (default is `desc`) |

## Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 200<span> - An array of trainees</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": [
        {
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
          "withdrawal_another_reason": null,
          "placement_detail": null,
          "ukprn": "10000571",
          "ethnicity": "120",
          "course_qualification": "QTS",
          "course_title": null,
          "course_level": "undergrad",
          "course_itt_start_date": "2022-09-01",
          "course_age_range": null,
          "expected_end_date": "2023-07-01",
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
        }
      ]
    }
    </pre>
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
          "message": "No trainees found"
        }
      ]
    }
    </pre>
  </div>
</details>

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 401<span> - Unauthorized</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "error": "Unauthorized"
    }
    </pre>
  </div>
</details>

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 422<span> - Unprocessable Entity</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "message": "Validation failed: 1 error prohibited this request being run",
      "errors": {
        "status": [
          "busy is not a valid status"
        ]
      }
    }
    </pre>
  </div>
</details>