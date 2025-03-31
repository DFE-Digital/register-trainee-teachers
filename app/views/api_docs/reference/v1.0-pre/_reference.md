This API allows you to access information about trainees and provides endpoints to update and create trainee data.

## Contents

- [API versioning strategy](#api-versioning-strategy)
- [Developing on the API](#developing-on-the-api)
    - [OpenAPI](#openapi)
    - [Authentication](#authentication)
- [Endpoints](#endpoints)
    - [GET /info](#code-get-info-code)
    - [GET /trainees](#code-get-trainees-code)
    - [GET /trainees/{trainee_id}](#code-get-trainees-trainee_id-code)
    - [GET /trainees/{trainee_id}/placements](#code-get-trainees-trainee_id-placements-code)
    - [GET /trainees/{trainee_id}/placements/{placement_id}](#code-get-trainees-trainee_id-placements-placement_id-code)
    - [GET /trainees/{trainee_id}/degrees](#code-get-trainees-trainee_id-degrees-code)
    - [GET /trainees/{trainee_id}/degrees/{degree_id}](#code-get-trainees-trainee_id-degrees-degree_id-code)
    - [POST /trainees](#code-post-trainees-code)
    - [POST /trainees/{trainee_id}/placements](#code-post-trainees-trainee_id-placements-code)
    - [POST /trainees/{trainee_id}/degrees](#code-post-trainees-trainee_id-degrees-code)
    - [POST /trainees/{trainee_id}/recommend-for-qts](#code-post-trainees-trainee_id-recommend-for-qts-code)
    - [POST /trainees/{trainee_id}/defer](#code-post-trainees-trainee_id-defer-code)
    - [POST /trainees/{trainee_id}/withdraw](#code-post-trainees-trainee_id-withdraw-code)
    - [PUT|PATCH /trainees/{trainee_id}](#code-put-patch-trainees-trainee_id-code)
    - [PUT|PATCH /trainees/{trainee_id}/placements/{placement_id}](#code-put-patch-trainees-trainee_id-placements-placement_id-code)
    - [PUT|PATCH /trainees/{trainee_id}/degrees/{degree_id}](#code-put-patch-trainees-trainee_id-degrees-degree_id-code)
    - [DELETE /trainees/{trainee_id}/placements/{placement_id}](#code-delete-trainees-trainee_id-placements-placement_id-code)
    - [DELETE /trainees/{trainee_id}/degrees/{degree_id}](#code-delete-trainees-trainee_id-degrees-degree_id-code)
- [Objects](#objects)
    - [Trainee](#trainee-object)
    - [Placement](#placement-object)
    - [Degree](#degree-object)
- [Field lengths summary](#field-lengths-summary)

---

## API versioning strategy

Find out about [how we make updates to the API](/api-docs#api-versioning-strategy), including:

- the difference between breaking and non-breaking changes
- how the API version number reflects changes
- using the correct version of the API

---

## Developing on the API

### OpenAPI

The OpenAPI spec for this API is <a href="/api-docs/v1.0-pre/openapi" target="_blank">available in YAML format</a>.

### Authentication

All requests must be accompanied by an `Authorization` request header (not as part of the URL) in the following format:

`Authorization: Bearer {token}`

Unauthenticated requests will receive an `UnauthorizedResponse` with a `401` status code.

Authentication tokens will be provided by the Register team.

---


## Endpoints

### `GET /info`

Provides general information about the API.

#### Request

`GET /api/v1.0-pre/info`

#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 200<span> - Information about the API status</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "status": "ok"
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

---

### `GET /trainees`

Get many trainees.

Note that this endpoint always returns the trainees for a single academic
cycle. If no academic cycle parameter is specified we return trainees in the
current academic cycle.

#### Request

`GET /api/v1.0-pre/trainees`

#### Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **academic_cycle** | query | string | false | The academic cycle year (default is the current academic cycle). |
| **status** | query | string | false | Include only trainees with a particular status. Valid values are `course_not_yet_started`, `in_training`,  `deferred`, `awarded`,  `withdrawn` |
| **since** | query | string | false | Include only trainees changed or created on or since a date and time. DateTimes should be in ISO 8601 format. |
| **has_trn** | query | boolean | false | Include only trainees with or without a `trn` |
| **page** | query | integer | false | Page number (defaults to 1, the first page). |
| **per_page** | query | integer | false | Number of records to return per page (default is 50) |
| **sort_order** | query | string | false | Sort in ascending or descending order. Valid values are `asc` or `desc` (default is `desc`) |

#### Possible responses

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
          "withdrawal_future_interest": null,
          "withdrawal_trigger": null,
          "withdrawal_reasons": null,
          "withdrawal_another_reason": null,
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
---

### `GET /trainees/{trainee_id}`

Get a single trainee.

#### Request

`GET /api/v1.0-pre/trainees/{trainee_id}`

#### Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |

#### Possible responses

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
        "withdrawal_future_interest": null,
        "withdrawal_trigger": null,
        "withdrawal_reasons": null,
        "withdrawal_another_reason": null,
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
          "message": "Trainee(s) not found"
        }
      ]
    }
    </pre>
  </div>
</details>

---

### `GET /trainees/{trainee_id}/placements`

Get many placements for a trainee.

#### Request

`GET /api/v1.0-pre/trainees/{trainee_id}/placements`

#### Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |

#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 200<span> - An array of placements</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": [
        {
          "placement_id": "AXsRAS4LfwZZXvSX7aAfNUb4",
          "school_id": 26214,
          "urn": "123456",
          "name": "Meadow Creek School",
          "postcode": "AB1 2CD",
          "created_at": "2024-01-18T08:02:42.672Z",
          "updated_at": "2024-01-18T08:02:42.672Z"
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
    }
    </pre>
  </div>
</details>

---

### `GET /trainees/{trainee_id}/placements/{placement_id}`

Get a single placement for a trainee.

#### Request

`GET /api/v1.0-pre/trainees/{trainee_id}/placements/{placement_id}`

#### Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |
| **placement_id** | path | string | true | The unique ID of the placement |

#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 200<span> - A placement</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": {
        "placement_id": "AXsRAS4LfwZZXvSX7aAfNUb4",
        "school_id": 26214,
        "urn": "123456",
        "name": "Meadow Creek School",
        "postcode": "AB1 2CD",
        "created_at": "2024-01-18T08:02:42.672Z",
        "updated_at": "2024-01-18T08:02:42.672Z"
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
          "message": "Placement(s) not found"
        }
      ]
    }
    </pre>
  </div>
</details>

---

### `GET /trainees/{trainee_id}/degrees`

Get many degrees for a trainee.

#### Request

`GET /api/v1.0-pre/trainees/{trainee_id}/degrees`

#### Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |

#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 200<span> - An array of degrees</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": [
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

---

### `GET /trainees/{trainee_id}/degrees/{degree_id}`

Get a single degree for a trainee.

#### Request

`GET /api/v1.0-pre/trainees/{trainee_id}/degrees/{degree_id}`

#### Parameters

| **Parameter**  | **In**  | **Type** | **Required** | **Description**        |
| -------------  | ------- | -------- | ------------ | ---------------------------- |
| **trainee_id** | path    | string   | true         | The unique ID of the trainee |
| **degree_id**  | path    | string   | true         | The unique ID of the degree  |

#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 200<span> - A degree</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": {
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

---

### `POST /trainees`

Create a trainee.

#### Request

`POST /api/v1.0-pre/trainees`

#### Request body

Trainee details

<dl class="govuk-summary-list">
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>data</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        <a class="govuk-link" href="#trainee-object">Trainee</a> object with nested <a class="govuk-link" href="#placement-object">Placement</a> and <a class="govuk-link" href="#degree-object">Degree</a> objects
      </p>
    </dd>
  </div>
</dl>

<details class="govuk-details">
  <summary class="govuk-details__summary">Example request body</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": {
        "first_names": "John",
        "last_name": "Doe",
        "previous_last_name": "Smith",
        "date_of_birth": "1990-01-01",
        "sex": "99",
        "email": "john.doe@example.com",
        "nationality": "GB",
        "training_route": "11",
        "itt_start_date": "2023-01-01",
        "itt_end_date": "2023-10-01",
        "course_subject_one": "100346",
        "study_mode": "63",
        "disability1": "58",
        "disability2": "57",
        "degrees_attributes": [
          {
            "grade": "02",
            "subject": "100485",
            "institution": "0117",
            "uk_degree": "083",
            "graduation_year": "2003"
          }
        ],
        "placements_attributes": [
          {
            "name": "Placement",
            "urn": "900020"
          }
        ],
        "itt_aim": 202,
        "itt_qualification_aim": "001",
        "course_year": "1",
        "course_age_range": "13913",
        "fund_code": "7",
        "funding_method": "4",
        "hesa_id": "0310261553101",
        "provider_trainee_id": "99157234/2/01",
        "pg_apprenticeship_start_date": "2024-03-11",
        "ethnicity": "142",
        "course_subject_two": "101410",
        "course_subject_three": "100366",
        "employing_school_urn": "790928",
        "ethnic_group": "mixed_ethnic_group",
        "ethnic_background": "Another Mixed background",
        "lead_partner_urn": "900020"
      }
    }
    </pre>
  </div>
</details>

#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 201<span> - A trainee</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": {
        "first_names": "John",
        "last_name": "Doe",
        "date_of_birth": "1990-01-01",
        "created_at": "2024-09-11T15:12:45.067Z",
        "updated_at": "2024-09-11T15:12:45.067Z",
        "email": "john.doe@example.com",
        "middle_names": null,
        "training_route": "11",
        "sex": "99",
        "diversity_disclosure": "diversity_disclosed",
        "ethnic_group": "mixed_ethnic_group",
        "ethnic_background": "Black Caribbean and White",
        "additional_ethnic_background": null,
        "disability_disclosure": "disabled",
        "course_subject_one": "100511",
        "itt_start_date": "2023-01-01",
        "outcome_date": null,
        "itt_end_date": "2023-10-01",
        "trn": null,
        "submitted_for_trn_at": "2024-09-11T15:12:45.345Z",
        "withdraw_date": null,
        "defer_date": null,
        "defer_reason": null,
        "recommended_for_award_at": null,
        "trainee_start_date": "2023-01-01",
        "reinstate_date": null,
        "course_min_age": 5,
        "course_max_age": 11,
        "course_subject_two": "100346",
        "course_subject_three": "101410",
        "awarded_at": null,
        "training_initiative": null,
        "study_mode": "63",
        "ebacc": false,
        "region": null,
        "course_education_phase": "primary",
        "course_uuid": null,
        "lead_partner_not_applicable": true,
        "employing_school_not_applicable": true,
        "submission_ready": true,
        "commencement_status": null,
        "discarded_at": null,
        "created_from_dttp": false,
        "hesa_id": "0310261553101",
        "additional_dttp_data": null,
        "created_from_hesa": false,
        "hesa_updated_at": null,
        "record_source": "api",
        "iqts_country": null,
        "hesa_editable": false,
        "withdrawal_future_interest": null,
        "withdrawal_trigger": null,
        "withdrawal_reasons": null,
        "withdrawal_another_reason": null,
        "slug_sent_to_dqt_at": null,
        "placement_detail": null,
        "provider_trainee_id": "99157234/2/01",
        "ukprn": "81239124",
        "ethnicity": "142",
        "disability1": "58",
        "disability2": "57",
        "course_qualification": "QTS",
        "course_title": null,
        "course_level": "undergrad",
        "course_itt_start_date": "2023-01-01",
        "course_age_range": "13914",
        "expected_end_date": "2023-10-01",
        "employing_school_urn": null,
        "lead_partner_ukprn": null,
        "lead_partner_urn": null,
        "fund_code": "7",
        "bursary_level": "4",
        "previous_last_name": "Smith",
        "itt_aim": "202",
        "course_study_mode": "63",
        "course_year": "1",
        "pg_apprenticeship_start_date": "2024-03-11",
        "funding_method": "4",
        "ni_number": null,
        "additional_training_initiative": null,
        "itt_qualification_aim": "001",
        "hesa_disabilities": {
          "disability1": "58",
          "disability2": "57"
        },
        "nationality": "GB",
        "withdraw_reasons": [],
        "placements": [
          {
            "urn": "900020",
            "name": "London School",
            "address": "URN 900020",
            "postcode": null,
            "created_at": "2024-09-11T15:12:45.090Z",
            "updated_at": "2024-09-11T15:12:45.090Z",
            "placement_id": "D8VsiEck1ueqigL1Pu9ESAaR"
          }
        ],
        "degrees": [
          {
            "uk_degree": "083",
            "non_uk_degree": null,
            "created_at": "2024-09-11T15:12:45.069Z",
            "updated_at": "2024-09-11T15:12:45.069Z",
            "subject": "100485",
            "institution": "0117",
            "graduation_year": 2003,
            "grade": "02",
            "country": null,
            "other_grade": null,
            "institution_uuid": "1271f34a-2887-e711-80d8-005056ac45bb",
            "uk_degree_uuid": "1b6a5652-c197-e711-80d8-005056ac45bb",
            "subject_uuid": "e78170f0-5dce-e911-a985-000d3ab79618",
            "grade_uuid": "e2fe18d4-8655-47cf-ab1a-8c3e0b0f078f",
            "degree_id": "cPTm9iXPbLzER8UqReEFGvNn"
          }
        ],
        "state": "submitted_for_trn",
        "trainee_id": "EMHhWRF33g53PReREX6rdPwd",
        "application_id": null
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
  <summary class="govuk-details__summary">HTTP 409<span> - Conflict</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "errors": [
        {
          "error": "Conflict",
          "message": "This trainee is already in Register"
        }
      ],
      "data": [
        {
          "first_names": "John",
          "last_name": "Doe",
          "date_of_birth": "1990-01-01",
          "created_at": "2024-09-11T15:12:45.067Z",
          "updated_at": "2024-09-11T15:12:45.067Z",
          "email": "john.doe@example.com",
          "middle_names": null,
          "training_route": "11",
          "sex": "99",
          "diversity_disclosure": "diversity_disclosed",
          "ethnic_group": "mixed_ethnic_group",
          "ethnic_background": "Black Caribbean and White",
          "additional_ethnic_background": null,
          "disability_disclosure": "disabled",
          "course_subject_one": "100511",
          "itt_start_date": "2023-01-01",
          "outcome_date": null,
          "itt_end_date": "2023-10-01",
          "trn": null,
          "submitted_for_trn_at": "2024-09-11T15:12:45.345Z",
          "withdraw_date": null,
          "defer_date": null,
          "defer_reason": null,
          "recommended_for_award_at": null,
          "trainee_start_date": "2023-01-01",
          "reinstate_date": null,
          "course_min_age": 5,
          "course_max_age": 11,
          "course_subject_two": "100346",
          "course_subject_three": "101410",
          "awarded_at": null,
          "training_initiative": null,
          "study_mode": "63",
          "ebacc": false,
          "region": null,
          "course_education_phase": "primary",
          "course_uuid": null,
          "lead_partner_not_applicable": true,
          "employing_school_not_applicable": true,
          "submission_ready": true,
          "commencement_status": null,
          "discarded_at": null,
          "created_from_dttp": false,
          "hesa_id": "0310261553101",
          "additional_dttp_data": null,
          "created_from_hesa": false,
          "hesa_updated_at": null,
          "record_source": "api",
          "iqts_country": null,
          "hesa_editable": false,
          "withdraw_reasons_dfe_details": null,
          "slug_sent_to_dqt_at": null,
          "placement_detail": null,
          "provider_trainee_id": "99157234/2/01",
          "ukprn": "81239124",
          "ethnicity": "142",
          "disability1": "58",
          "disability2": "57",
          "course_qualification": "QTS",
          "course_title": null,
          "course_level": "undergrad",
          "course_itt_start_date": "2023-01-01",
          "course_age_range": "13914",
          "expected_end_date": "2023-10-01",
          "employing_school_urn": null,
          "lead_partner_ukprn": null,
          "lead_partner_urn": null,
          "fund_code": "7",
          "bursary_level": "4",
          "previous_last_name": "Smith",
          "itt_aim": "202",
          "course_study_mode": "63",
          "course_year": "1",
          "pg_apprenticeship_start_date": "2024-03-11",
          "funding_method": "4",
          "ni_number": null,
          "additional_training_initiative": null,
          "itt_qualification_aim": "001",
          "hesa_disabilities": {
            "disability1": "58",
            "disability2": "57"
          },
          "nationality": "GB",
          "withdraw_reasons": [],
          "placements": [
            {
              "urn": "900020",
              "name": "London School",
              "address": "URN 900020",
              "postcode": null,
              "created_at": "2024-09-11T15:12:45.090Z",
              "updated_at": "2024-09-11T15:12:45.090Z",
              "placement_id": "D8VsiEck1ueqigL1Pu9ESAaR"
            }
          ],
          "degrees": [
            {
              "uk_degree": "083",
              "non_uk_degree": null,
              "created_at": "2024-09-11T15:12:45.069Z",
              "updated_at": "2024-09-11T15:12:45.069Z",
              "subject": "100485",
              "institution": "0117",
              "graduation_year": 2003,
              "grade": "02",
              "country": null,
              "other_grade": null,
              "institution_uuid": "1271f34a-2887-e711-80d8-005056ac45bb",
              "uk_degree_uuid": "1b6a5652-c197-e711-80d8-005056ac45bb",
              "subject_uuid": "e78170f0-5dce-e911-a985-000d3ab79618",
              "grade_uuid": "e2fe18d4-8655-47cf-ab1a-8c3e0b0f078f",
              "degree_id": "cPTm9iXPbLzER8UqReEFGvNn"
            }
          ],
          "state": "submitted_for_trn",
          "trainee_id": "EMHhWRF33g53PReREX6rdPwd",
          "application_id": null
        }
      ]
    }
    </pre>
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
          "message": "First names can't be blank"
        }
      ]
    }
    </pre>
  </div>
</details>

#### Trainee duplication validations
When creating a trainee, a duplication validation is performed to ensure that duplicate trainees are not created. A trainee will be flagged as a duplicate if:

<ul class='govuk-list govuk-list--bullet'>
  <li>there is an exact match on <code>date_of_birth</code> and <code>training_route</code> and <code>last_name</code> (ignoring case)</li>
  <li><strong>and</strong> their start date (based on <code>trainee_start_date</code> or <code>itt_start_date</code>) is in the same academic year</li>
  <li><strong>and</strong> there is a match on either <code>first_names</code> (ignoring case, punctuation, and special characters) or <code>email</code> (ignoring case)</li>
</ul>

If the new trainee is flagged as a duplicate, an error message will be returned indicating it is a duplicate.

This validation ensures that duplicate trainee records are not created, and helps to maintain the data accuracy and data integrity.

---

### `POST /trainees/{trainee_id}/placements`

Create a placement for this trainee.

#### Request

`POST /api/v1.0-pre/trainees/{trainee_id}/placements`

#### Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |

#### Request body

Placement details

<dl class="govuk-summary-list">
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>data</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        <a class="govuk-link" href="#placement-object">Placement</a> object
      </p>
    </dd>
  </div>
</dl>

<details class="govuk-details">
  <summary class="govuk-details__summary">Example request body</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": {
        "urn": "343452",
        "name": "Oxford School",
        "postcode": "OX1 1AA"
      }
    }
    </pre>
  </div>
</details>

#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 201<span> - A placement</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": {
        "placement_id": "AXsRAS4LfwZZXvSX7aAfNUb4",
        "school_id": 26214,
        "urn": "123456",
        "name": "Meadow Creek School",
        "postcode": "AB1 2CD",
        "created_at": "2024-01-18T08:02:42.672Z",
        "updated_at": "2024-01-18T08:02:42.672Z"
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
          "message": "Trainee(s) not found"
        }
      ]
    }
    </pre>
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
          "message": "Name can't be blank"
        }
      ]
    }
    </pre>
  </div>
</details>

---


### `POST /trainees/{trainee_id}/degrees`

Create a degree for this trainee.

#### Request

`POST /api/v1.0-pre/trainees/{trainee_id}/degrees`

#### Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |

#### Request body

Degree details

<dl class="govuk-summary-list">
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>data</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        <a class="govuk-link" href="#degree-object">Degree</a> object
      </p>
    </dd>
  </div>
</dl>

<details class="govuk-details">
  <summary class="govuk-details__summary">Example request body</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
    "data": {
      "grade": "02",
      "subject": "100425",
      "institution": "0117",
      "uk_degree": "083",
      "graduation_year": "2015-01-01",
      "country": "GB"
      }
    }
    </pre>
  </div>
</details>

#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 201<span> - A degree</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": [
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
          "message": "Trainee(s) not found"
        }
      ]
    }
    </pre>
  </div>
</details>

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 409<span> - Conflict</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "errors": [
        {
          "error": "Conflict",
          "message": "This is a duplicate degree"
        }
      ],
      "data": [
        {
          "uk_degree": null,
          "non_uk_degree": null,
          "created_at": "2025-02-17T15:43:01.197Z",
          "updated_at": "2025-02-17T15:43:01.197Z",
          "subject": "100734",
          "institution": "0023",
          "graduation_year": 2022,
          "grade": "01",
          "country": null,
          "other_grade": null,
          "institution_uuid": "dc70f34a-2887-e711-80d8-005056ac45bb",
          "uk_degree_uuid": "3e042de2-a453-47dc-9452-90a23399e9ee",
          "subject_uuid": "338370f0-5dce-e911-a985-000d3ab79618",
          "grade_uuid": "8741765a-13d8-4550-a413-c5a860a59d25",
          "degree_id": "ao53fi469ar7kjfc04uys0dc"
        }
      ]
    }
    </pre>
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
          "message": "Param is missing or the value is empty: data"
        }
      ]
    }
    </pre>
  </div>
</details>

#### Degree duplication validations
When creating a degree, a duplication validation is performed to ensure that duplicate degrees are not created. This validation checks the following fields:

<ul class='govuk-list govuk-list--bullet'>
  <li><code>subject</code></li>
  <li><code>graduation_year</code></li>
  <li><code>country</code></li>
  <li><code>uk_degree</code></li>
  <li><code>non_uk_degree</code></li>
  <li><code>grade</code></li>
</ul>

If a degree with these exact fields already exists, it is considered a duplicate.

This validation ensures that duplicate degree records for the same trainee are not created, and helps to maintain the data accuracy and data integrity.

---

### `POST /trainees/{trainee_id}/recommend-for-qts`

Recommend a trainee for a QTS Award.

#### Request

`POST /api/v0.1/trainees/{trainee_id}/recommend-for-qts`

#### Parameters

| **Parameter**	| **In**	| **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |

#### Request body

Recommendation details

<div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
  <dt class="govuk-summary-list__key"><code>qts_standards_met_date</code></dt>
  <dd class="govuk-summary-list__value">
    <p class="govuk-body">
      string, required
    </p>
    <p class="govuk-body">
      The date when the Trainee met the QTS standards. Dates should be in ISO 8601 format.
    </p>
    <p class="govuk-body">
      Example: <code>2000-01-01</code>
    </p>
  </dd>
</div>

<details class="govuk-details">
  <summary class="govuk-details__summary">Example request body</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": {
        "qts_standards_met_date": "2024-06-17"
      }
    }
    </pre>
  </div>
</details>

#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 202<span> - A trainee</span></summary>
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
        "state": "recommended_for_award",
        "withdraw_date": null,
        "defer_date": "2023-10-17",
        "defer_reason": null,
        "recommended_for_award_at": "2024-06-17T09:05:48Z",
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
          "message": "Trainee(s) not found"
        }
      ]
    }
    </pre>
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
          "message": "Qts standards met date can't be blank"
        }
      ]
    }
    </pre>
  </div>
</details>

---

### `POST /trainees/{trainee_id}/defer`

Defer a trainee.

#### Request

`POST /api/v1.0-pre/trainees/{trainee_id}/defer`

#### Parameters

| **Parameter**	| **In**	| **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |

#### Request body

Deferral details

<div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
  <dt class="govuk-summary-list__key"><code>defer_date</code></dt>
  <dd class="govuk-summary-list__value">
    <p class="govuk-body">
      string, required
    </p>
    <p class="govuk-body">
      The date when the Trainee deferred. Dates should be in ISO 8601 format.
    </p>
    <p class="govuk-body">
      Example: <code>2000-01-01</code>
    </p>
  </dd>
</div>
<div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
  <dt class="govuk-summary-list__key"><code>defer_reason</code></dt>
  <dd class="govuk-summary-list__value">
    <p class="govuk-body">
      string (limited to 500 characters)
    </p>
    <p class="govuk-body">
      The reason that the Trainee deferred.
    </p>
    <p class="govuk-body">
      Example: <code>Cannot attend course</code>
    </p>
  </dd>
</div>

<details class="govuk-details">
  <summary class="govuk-details__summary">Example request body</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": {
        "defer_date": "2024-06-17",
        "defer_reason": "The trainee's circumstances changed so they want to defer"
      }
    }
    </pre>
  </div>
</details>

#### Possible responses

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
        "state": "recommended_for_award",
        "withdraw_date": null,
        "defer_date": "2024-06-17",
        "defer_reason": null,
        "recommended_for_award_at": nil,
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
          "message": "Trainee(s) not found"
        }
      ]
    }
    </pre>
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
          "message": "Defer date can't be blank"
        }
      ]
    }
    </pre>
  </div>
</details>

---

### `POST /trainees/{trainee_id}/withdraw`

Withdraw a trainee.

#### Request

`POST /api/v1.0-pre/trainees/{trainee_id}/withdraw`

#### Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |

#### Request body

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
      The reason(s) for the withdrawal. Valid values with trigger <code>trainee</code> are <code>unacceptable_behaviour</code>, <code>did_not_make_progress</code>, <code>lack_of_progress_during_placements</code>, <code>trainee_workload_issues</code>, <code>not_meeting_qts_standards</code>, <code>change_in_personal_or_health_circumstances</code>, <code>does_not_want_to_become_a_teacher</code>, <code>never_intended_to_obtain_qts</code>, <code>moved_to_different_itt_course</code>, <code>trainee_chose_to_withdraw_another_reason</code>.
      Valid values with trigger <code>provider</code> are <code>record_added_in_error</code>, <code>mandatory_reasons</code>, <code>stopped_responding_to_messages</code>, <code>unacceptable_behaviour</code>, <code>lack_of_progress_during_placements</code>, <code>did_not_make_progress</code>, <code>not_meeting_qts_standards</code>, <code>had_to_withdraw_trainee_another_reason</code>.
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

<details class="govuk-details">
  <summary class="govuk-details__summary">Example request body</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": {
        "trigger": "provider,
        "future_interest": "no",
        "withdraw_date": "2025-03-05",
        "reasons": [
          "unacceptable_behavior",
          "had_to_withdraw_trainee_another_reason"
        ],
        "another_reason": "Bespoke reason"
      }
    }
    </pre>
  </div>
</details>

#### Possible responses

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
          "message": "Trainee(s) not found"
        }
      ]
    }
    </pre>
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
    }
    </pre>
  </div>
</details>

---

### `DELETE /trainees/{trainee_id}/degrees/{degree_id}`

Deletes an existing degree for this trainee.

#### Request

`DELETE /api/v1.0-pre/trainees/{trainee_id}/degrees/{degree_id}`

#### Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |
| **degree_id** | path | string | true | The unique ID of the degree |

#### Possible responses

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

---

### `PUT|PATCH /trainees/{trainee_id}`

Updates an existing trainee.

#### Request

`PUT /api/v1.0-pre/trainees/{trainee_id}`

or

`PATCH /api/v1.0-pre/trainees/{trainee_id}`

#### Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |

#### Request body

Trainee details

<dl class="govuk-summary-list">
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>data</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        <a class="govuk-link" href="#trainee-object">Trainee</a> object
      </p>
    </dd>
  </div>
</dl>

<details class="govuk-details">
  <summary class="govuk-details__summary">Example request body</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": {
        "first_names": "Ruby Joy"
      }
    }
    </pre>
  </div>
</details>

#### Possible responses

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
          "message": "Trainee(s) not found"
        }
      ]
    }
    </pre>
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
          "message": "First names is too long (maximum is 60 characters)"
        }
      ]
    }
    </pre>
  </div>
</details>

---

### `PUT|PATCH /trainees/{trainee_id}/placements/{placement_id}`

Updates an existing placement for this trainee.

#### Request

`PUT /api/v1.0-pre/trainees/{trainee_id}/placements/{placement_id}`

or

`PATCH /api/v1.0-pre/trainees/{trainee_id}/placements/{placement_id}`

#### Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |
| **placement_id** | path | string | true | The unique ID of the placement |

#### Request body

Placement details

<dl class="govuk-summary-list">
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>data</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        <a class="govuk-link" href="#placement-object">Placement</a> object
      </p>
    </dd>
  </div>
</dl>

<details class="govuk-details">
  <summary class="govuk-details__summary">Example request body</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": {
        "urn": "137523",
        "name": "Wellsway School"
      }
    }
    </pre>
  </div>
</details>

#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 200<span> - A placement</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": {
        "urn": "137523",
        "name": "Wellsway School",
        "address": "URN 137523",
        "postcode": null,
        "placement_id": 4fjxTZgHxFgzYrwB8L3UNRvM,
        "created_at": "2024-03-19T22:23:48.619Z",
        "updated_at": "2024-03-19T22:23:48.619Z"
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
          "message": "Placement(s) not found"
        }
      ]
    }
    </pre>
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
          "message": "Name can't be blank"
        }
      ]
    }
    </pre>
  </div>
</details>

---

### `PUT|PATCH /trainees/{trainee_id}/degrees/{degree_id}`

Updates an existing degree for this trainee.


#### Request

`PUT /api/v1.0-pre/trainees/{trainee_id}/degrees/{degree_id}`

or

`PATCH /api/v1.0-pre/trainees/{trainee_id}/degrees/{degree_id}`

#### Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |
| **degree_id** | path | string | true | The unique ID of the degree |

#### Request body

Degree details

<dl class="govuk-summary-list">
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>data</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        <a class="govuk-link" href="#degree-object">Degree</a> object
      </p>
    </dd>
  </div>
</dl>

<details class="govuk-details">
  <summary class="govuk-details__summary">Example request body</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": {
        "grade": "Lower second-class honours (2:2)"
      }
    }
    </pre>
  </div>
</details>


#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 200<span> - A degree</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": {
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

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 409<span> - Conflict</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "errors": [
        {
          "error": "Conflict",
          "message": "This is a duplicate degree"
        }
      ],
      "data": [
        {
          "uk_degree": null,
          "non_uk_degree": null,
          "created_at": "2025-02-17T15:43:01.197Z",
          "updated_at": "2025-02-17T15:43:01.197Z",
          "subject": "100734",
          "institution": "0023",
          "graduation_year": 2022,
          "grade": "01",
          "country": null,
          "other_grade": null,
          "institution_uuid": "dc70f34a-2887-e711-80d8-005056ac45bb",
          "uk_degree_uuid": "3e042de2-a453-47dc-9452-90a23399e9ee",
          "subject_uuid": "338370f0-5dce-e911-a985-000d3ab79618",
          "grade_uuid": "8741765a-13d8-4550-a413-c5a860a59d25",
          "degree_id": "ao53fi469ar7kjfc04uys0dc"
        }
      ]
    }
    </pre>
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
          "message": "Subject is not included in the list"
        }
      ]
    }
    </pre>
  </div>
</details>

#### Degree duplication validations
When updating a degree, a duplication validation is performed to ensure that duplicate degrees are not created. This validation checks the following fields:

<ul class='govuk-list govuk-list--bullet'>
  <li><code>subject</code></li>
  <li><code>graduation_year</code></li>
  <li><code>country</code></li>
  <li><code>uk_degree</code></li>
  <li><code>non_uk_degree</code></li>
  <li><code>grade</code></li>
</ul>

If a degree with these exact fields already exists, it is considered a duplicate.

This validation ensures that duplicate degree records for the same trainee are not created, and helps to maintain the data accuracy and data integrity.

---

### `DELETE /trainees/{trainee_id}/placements/{placement_id}`

Deletes an existing placement for this trainee.

#### Request

`DELETE /api/v1.0-pre/trainees/{trainee_id}/placements/{placement_id}`

#### Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |
| **placement_id** | path | string | true | The unique ID of the placement |

#### Possible responses

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
          "message": "Placement(s) not found"
        }
      ]
    }
    </pre>
  </div>
</details>

---

### `DELETE /trainees/{trainee_id}/degrees/{degree_id}`

Deletes an existing degree for this trainee.

#### Request

`DELETE /api/v1.0-pre/trainees/{trainee_id}/degrees/{degree_id}`

#### Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |
| **degree_id** | path | string | true | The unique ID of the degree |

#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 200<span> - A degree</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": [
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

---


## Objects

### Trainee object

<dl class="govuk-summary-list">
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>trainee_id</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 24 characters)
      </p>
      <p class="govuk-body">
        The unique ID of the trainee in the Register system. Used to identify the trainee when using <a href="/api-docs/reference#contents">endpoints</a> which require a <code>trainee_id</code>.
      </p>
      <p class="govuk-body">
        Example: <code>37T2Vm9aipqSVokbhWUMjedu</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>provider_trainee_id</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 20 characters)
      </p>
      <p class="govuk-body">
        The unique ID of the trainee in the Provider’s student record system (SRS). Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/ownstu">HESA provider’s own identifier for student field</a>.
      </p>
      <p class="govuk-body">
        Example: <code>99157234</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>application_id</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        integer
      </p>
      <p class="govuk-body">
        The unique ID of the application choice in the Apply system.
      </p>
      <p class="govuk-body">
        Example: <code>123456</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>trn</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 7 characters)
      </p>
      <p class="govuk-body">
        The reference number allocated to each trainee prior to course completion.
      </p>
      <p class="govuk-body">
        Example: <code>2248531</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>first_names</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 60 characters), required
      </p>
      <p class="govuk-body">
        The first names of the trainee.
      </p>
      <p class="govuk-body">
        Example: <code>Ruby Joy</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>last_name</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 60 characters), required
      </p>
      <p class="govuk-body">
        The last name of the trainee.
      </p>
      <p class="govuk-body">
        Example: <code>Smith</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>previous_last_name</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 60 characters)
      </p>
      <p class="govuk-body">
        The last name of the trainee immediately before their current last name.
      </p>
      <p class="govuk-body">
        Example: <code>Jones</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>date_of_birth</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string, required
      </p>
      <p class="govuk-body">
        The date of birth of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/birthdte">HESA date of birth field</a>
      </p>
      <p class="govuk-body">
        Example: <code>2000-01-01</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>sex</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 2 characters), required
      </p>
      <p class="govuk-body">
        The sex of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/sexid">HESA sex identifier field</a>
      </p>
      <p class="govuk-body">
        Example: <code>10</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>nationality</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 2 characters)
      </p>
      <p class="govuk-body">
        The nationality of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/nation">HESA nationality field</a>
      </p>
      <p class="govuk-body">
        Example: <code>GB</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>email</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 80 characters), required
      </p>
      <p class="govuk-body">
        The email address of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/nqtemail">HESA email addresses field</a>
      </p>
      <p class="govuk-body">
        Example: <code>trainee123@example.com</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>ethnicity</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 3 characters)
      </p>
      <p class="govuk-body">
        The ethnicity of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/ethnic">HESA ethnicity field</a>. The values for <code>ethnic_background</code> and <code>ethnic_group</code> will be set based on the <code>ethnicity</code> value.
      </p>
      <p class="govuk-body">
        Example: <code>120</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>disability1</code> to <code>disability9</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 2 characters)
      </p>
      <p class="govuk-body">
        The type of disabilities that the trainee has. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/disable">HESA disability field</a>
      </p>
      <p class="govuk-body">
        Example: <code>58</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>itt_aim</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 3 characters), required
      </p>
      <p class="govuk-body">
        The general qualification aim of the course in terms of qualifications and professional statuses. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/ittaim">HESA ITT qualification aim field</a>
      </p>
      <p class="govuk-body">
        Example: <code>201</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>training_route</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 2 characters), required
      </p>
      <p class="govuk-body">
        The training route that the trainee is on. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/entryrte">HESA entry route field</a>
      </p>
      <p class="govuk-body">
        Example: <code>11</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>itt_qualification_aim</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 3 characters), required if <code>itt_aim</code> is <code>202</code>
      </p>
      <p class="govuk-body">
        The qualification aim of the trainee’s course. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/qlaim">HESA qualification aim field</a>.
      </p>
      <p class="govuk-body">
        Example: <code>004</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>course_subject_one</code>, <code>course_subject_two</code>, <code>course_subject_three</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 6 characters), <code>course_subject_one</code> is required
      </p>
      <p class="govuk-body">
        The subjects included in the trainee’s course. The first subject is the main one. It represents the bursary or scholarship available if applicable. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/sbjca">HESA subject of ITT course field</a>.
      </p>
      <p class="govuk-body">
        Example: <code>100425</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>study_mode</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 2 characters), required
      </p>
      <p class="govuk-body">
        This indicates whether the trainee’s course is full-time or part-time. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/mode">HESA mode of study field</a>.
      </p>
      <p class="govuk-body">
        Example: <code>01</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>itt_start_date</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string, required
      </p>
      <p class="govuk-body">
        The start date of the Initial Teacher Training part of their course. Dates should be in ISO 8601 format.
      </p>
      <p class="govuk-body">
        Example: <code>2024-03-11</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>itt_end_date</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string, required
      </p>
      <p class="govuk-body">
        The end date of the Initial Teacher Training part of their course. Dates should be in ISO 8601 format.
      </p>
      <p class="govuk-body">
        Example: <code>2025-03-11</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>course_year</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 2 characters), required
      </p>
      <p class="govuk-body">
        The year number of the course that the trainee is currently studying. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/yearprg">HESA year of course field</a>
      </p>
      <p class="govuk-body">
        Example: <code>2</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>course_min_age</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        integer
      </p>
      <p class="govuk-body">
        The lower bound of the age range of children taught on the course (read-only).
      </p>
      <p class="govuk-body">
        Example: <code>7</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>course_max_age</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        integer
      </p>
      <p class="govuk-body">
        The upper bound of the age range of children taught on the course (read-only).
      </p>
      <p class="govuk-body">
        Example: <code>11</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>course_age_range</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 5 characters), required
      </p>
      <p class="govuk-body">
        The age range of children taught on the course. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/ittphsc">HESA ITT phase/scope field</a>
      </p>
      <p class="govuk-body">
        Example: <code>13918</code>
      </p>
      <p class="govuk-body">
        The following HESA values are invalid for this field:
        <ul class='govuk-list govuk-list--bullet'>
          <li><code>99801</code> - Teacher training qualification: Further education/Higher education</li>
          <li><code>99803</code> - Teacher training qualification: Other</li>
        </ul>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>lead_partner_urn</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 6 characters)
      </p>
      <p class="govuk-body">
        The Unique Reference Number (URN) of the lead partner for the trainee.
      </p>
      <p class="govuk-body">
        Example: <code>123456</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>lead_partner_ukprn</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 8 characters)
      </p>
      <p class="govuk-body">
        The UK Provider Reference Number (UKPRN) of the lead partner for the trainee. If
        <code>lead_partner_urn</code> and <code>lead_partner_ukprn</code> are both provided,
        the <code>lead_partner_urn</code> will be used.
      </p>
      <p class="govuk-body">
        Example: <code>12345678</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>trainee_start_date</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string
      </p>
      <p class="govuk-body">
        The start date of the trainee on their ITT course. Dates should be in ISO 8601 format.
      </p>
      <p class="govuk-body">
        Example: <code>2024-03-11</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>pg_apprenticeship_start_date</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string
      </p>
      <p class="govuk-body">
        The start date of a trainee’s postgraduate teaching apprenticeship. Dates should be in ISO 8601 format.
      </p>
      <p class="govuk-body">
        Example: <code>2024-03-11</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>employing_school_urn</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 6 characters)
      </p>
      <p class="govuk-body">
        The Unique Reference Number (URN) of the employing school for School Direct salaried trainees.
      </p>
      <p class="govuk-body">
        Example: <code>123456</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>fund_code</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 1 characters), required
      </p>
      <p class="govuk-body">
        The funding eligibility of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/fundcode">HESA fundability code field</a>
      </p>
      <p class="govuk-body">
        Example: <code>7</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>funding_method</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 1 characters), required
      </p>
      <p class="govuk-body">
        The bursary level awarded to the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/burslev">HESA bursary level award field</a>
      </p>
      <p class="govuk-body">
        Example: <code>4</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>training_initiative</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 3 characters)
      </p>
      <p class="govuk-body">
        The main training initiative that the trainee is on. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/initiatives">HESA initiatives field</a>
      </p>
      <p class="govuk-body">
        Example: <code>009</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>additional_training_initiative</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 3 characters)
      </p>
      <p class="govuk-body">
        The secondary training initiative that the trainee is on. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/initiatives">HESA initiatives field</a>
      </p>
      <p class="govuk-body">
        Example: <code>025</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>hesa_id</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 17 characters), required
      </p>
      <p class="govuk-body">
        The HESA unique student identifier for the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/husid">HESA unique student identifier field</a>
      </p>
      <p class="govuk-body">
        Example: <code>1210007145123456</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>ni_number</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 9 characters)
      </p>
      <p class="govuk-body">
        The trainee’s National Insurance number.
      </p>
      <p class="govuk-body">
        Example: <code>BX5867459C</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>reinstate_date</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        date
      </p>
      <p class="govuk-body">
        The trainee’s reinstate date. (read-only)
      </p>
      <p class="govuk-body">
        Example: <code>2023-10-01</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>course_education_phase</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string
      </p>
      <p class="govuk-body">
        The trainee’s course education phase. (read-only)
      </p>
      <p class="govuk-body">
        Example: <code>primary</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>record_source</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string
      </p>
      <p class="govuk-body">
        The trainee’s record source. (read-only)
      </p>
      <p class="govuk-body">
        Possible values:
      </p>
      <ul>
        <li><code>manual</code></li>
        <li><code>api</code></li>
        <li><code>csv</code></li>
        <li><code>hesa</code></li>
        <li><code>apply</code></li>
        <li><code>dttp</code></li>
      </ul>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>state</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string
      </p>
      <p class="govuk-body">
        The trainee’s record state. (read-only)
      </p>
      <p class="govuk-body">
        Possible values:
      </p>
      <ul>
        <li><code>draft</code></li>
        <li><code>submitted_for_trn</code></li>
        <li><code>trn_received</code></li>
        <li><code>recommended_for_award</code></li>
        <li><code>withdrawn</code></li>
        <li><code>deferred</code></li>
        <li><code>awarded</code></li>
      </ul>
    </dd>
  </div>
</dl>

### Placement object

<dl class="govuk-summary-list">
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>placement_id</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 24 characters)
      </p>
      <p class="govuk-body">
        The unique ID of the placement in the Register system. Used to identify the placement when <a href="/api-docs/reference#code-put-patch-trainees-trainee_id-placements-placement_id-code">updating</a> or <a href="/api-docs/reference#code-delete-trainees-trainee_id-placements-placement_id-code">deleting</a>.
      </p>
      <p class="govuk-body">
        Example: <code>4QWdpfb2UJM1gdhKnsyKiVkj</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>urn</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 6 characters)
      </p>
      <p class="govuk-body">
        The URN of the school. Coded according to <a href="https://www.hesa.ac.uk/collection/c24053/e/plmntsch">HESA placement school field</a>
      </p>
      <p class="govuk-body">
        Example: <code>123456</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>name</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string, required if <code>urn</code> is not provided
      </p>
      <p class="govuk-body">
        The placement school or setting name.
      </p>
      <p class="govuk-body">
        Example: <code>Hedgehogs Nursery</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>postcode</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 8 characters)
      </p>
      <p class="govuk-body">
        The postcode of the placement school or setting.
      </p>
      <p class="govuk-body">
        Example: <code>AB1 2CD</code>
      </p>
    </dd>
  </div>
</dl>

### Degree object

<dl class="govuk-summary-list">
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>degree_id</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 24 characters)
      </p>
      <p class="govuk-body">
        The unique ID of the degree in the Register system. Used to identify the degree when <a href="/api-docs/reference#code-put-patch-trainees-trainee_id-degrees-degree_id-code">updating</a> or <a href="/api-docs/reference#code-delete-trainees-trainee_id-degrees-degree_id-code">deleting</a>.
      </p>
      <p class="govuk-body">
        Example: <code>37T2Vm9aipqSVokbhWUMjedu</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>country</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 2 characters), required if degree is <strong>not</strong> from the UK
      </p>
      <p class="govuk-body">
        The country where the degree was awarded. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/degctry">HESA degree country field</a>
      </p>
      <p class="govuk-body">
        Example: <code>US</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>grade</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 2 characters), required if degree is from the UK
      </p>
      <p class="govuk-body">
        The grade of the degree. Coded according to <a href="https://www.hesa.ac.uk/collection/c24053/e/degclss">HESA degree class field</a>
      </p>
      <p class="govuk-body">
        Example: <code>02</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>uk_degree</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 3 characters), required if degree is from the UK
      </p>
      <p class="govuk-body">
        The type of UK degree. Coded according to <a href="https://www.hesa.ac.uk/collection/c24053/e/degtype">HESA degree type field</a>
      </p>
      <p class="govuk-body">
        Example: <code>083</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>non_uk_degree</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 3 characters), required if degree is <strong>not</strong> from the UK
      </p>
      <p class="govuk-body">
        The type of non-UK degree. Coded according to <a href="https://www.hesa.ac.uk/collection/c24053/e/degtype">HESA degree type field</a>
      </p>
      <p class="govuk-body">
        Example: <code>051</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>subject</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 6 characters), required
      </p>
      <p class="govuk-body">
        The degree subject. Coded according to <a href="https://www.hesa.ac.uk/collection/c24053/e/degsbj">HESA degree subject field</a>
      </p>
      <p class="govuk-body">
        Example: <code>100425</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>institution</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 4 characters), required if degree is from the UK
      </p>
      <p class="govuk-body">
        The awarding institution. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/degest">HESA degree establishment field</a>
      </p>
      <p class="govuk-body">
        Example: <code>0116</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>graduation_year</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string, required
      </p>
      <p class="govuk-body">
        The year of graduation. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/degenddt">HESA degree end date field</a>
      </p>
      <p class="govuk-body">
        Example: <code>2012-07-31</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>locale_code</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string
      </p>
      <p class="govuk-body">
        The locale code `uk` or `non_uk` (read-only).
      </p>
      <p class="govuk-body">
        Example: <code>uk</code>
      </p>
    </dd>
  </div>
</dl>

## Field lengths summary

<table class="govuk-table">
  <thead class="govuk-table__head">
    <tr class="govuk-table__row">
      <th scope="col" class="govuk-table__header">Rule</th>
      <th scope="col" class="govuk-table__header govuk-table__header--numeric">Limit</th>
    </tr>
  </thead>
  <tbody class="govuk-table__body">
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.trainee_id.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">24</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.provider_trainee_id.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">20</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.trn.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">7</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.first_names.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">60</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.last_name.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">60</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.previous_last_name.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">60</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.sex.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">2</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.nationality.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">2</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.email.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">80</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.ethnicity.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">3</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.disability1.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">2</td>
    </tr>
        <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.disability2.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">2</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.disability3.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">2</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.disability4.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">2</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.disability5.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">2</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.disability6.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">2</td>
    </tr>
        <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.disability7.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">2</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.disability8.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">2</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.disability9.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">2</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.itt_aim.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">3</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.training_route.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">2</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.itt_qualification_aim.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">3</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.course_subject_one.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">6</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.course_subject_two.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">6</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.course_subject_three.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">6</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.study_mode.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">2</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.course_year.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">2</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.course_age_range.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">5</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.employing_school_urn.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">6</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.lead_partner_urn.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">6</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.lead_partner_ukprn.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">8</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.fund_code.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">1</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.funding_method.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">1</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.training_initiative.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">3</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.additional_training_initiative.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">3</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.hesa_id.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">17</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Trainee.properties.ni_number.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">9</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Placement.properties.name.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">255</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Placement.properties.placement_id.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">24</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Placement.properties.urn.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">6</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Placement.properties.postcode.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">8</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Degree.properties.degree_id.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">24</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Degree.properties.country.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">2</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Degree.properties.grade.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">2</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Degree.properties.uk_degree.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">3</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Degree.properties.non_uk_degree.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">255</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Degree.properties.subject.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">6</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Degree.properties.institution.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">4</td>
    </tr>
  </tbody>
</table>
