---
title: DELETE /trainees/{trainee_id}/degrees/{degree_id}
weight: 18
---

# `DELETE /trainees/{trainee_id}/degrees/{degree_id}`

Deletes an existing degree for this trainee.

## Request

`DELETE /api/v2025.0-rc/trainees/{trainee_id}/degrees/{degree_id}`

## Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |
| **degree_id** | path | string | true | The unique ID of the degree |

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
        "withdrawal_future_interest": null,
        "withdrawal_trigger": null,
        "withdrawal_reasons": null,
        "withdrawal_another_reason": null,
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
        "withdraw_reasons_dfe_details": null,
        "placement_detail": null,
        "ukprn": "10000571",
        "ethnicity": "120",
        "course_qualification": "QTS",
        "course_title": null,
        "course_level": "undergrad",
        "course_itt_start_date": "2022-09-01",
        "course_age_range": "13914",
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
        "degrees": []
      }
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
  <summary class="govuk-details__summary">HTTP 404<span> - Not found</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "errors": [
        {
          "error": "NotFound",
          "message": "Degree(s) not found"
        }
      ]
    }
    </pre>
  </div>
</details>