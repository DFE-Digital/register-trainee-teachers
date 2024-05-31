This API allows you to access information about trainees and provides endpoints to update and create trainee data.

## Contents

- [API versioning strategy](#api-versioning-strategy)
- [Draft version 0.1](#draft-version-0-1)
- [Developing on the API](#developing-on-the-api)
    - [Reference spreadsheet](#reference-spreadsheet)
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

## Draft version 0.1

Version 0.1 is a draft version of the API. It was released on 22 April 2024.

It is designed for testing and feedback purposes only.

It will have some seed data to help you test the API.

It will only be available on the `sandbox` environment.

---

## Developing on the API

### Reference spreadsheet

You can use the Register API reference spreadsheet to map trainee data from your student record system into the Register service via the Register API.

Register API reference spreadsheet contains the following information:

- field requirement
- entity
- description
- whether a field is optional or mandatory
- whether it allows multiple values
- minimum and maximum instances
- character length
- format rules
- HESA data type, alignment, code examples, labels, link to their data reference webpage and confirmation if the HESA validation is applicable

You must only use the reference spreadsheet v0.1 for use in testing and feedback of API v0.1 within the sandbox environment.

Download [Register API reference spreadsheet v0.1 (Excel)](/api-docs/reference/Register_API_Reference_v0.1.xlsx)

### OpenAPI

The OpenAPI spec for this API is <a href="/api-docs/v0.1/openapi" target="_blank">available in YAML format</a>.

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

`GET /api/v0.1/info`

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

`GET /api/v0.1/trainees`

#### Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **academic_cycle** | query | string | false | The academic cycle year (default is the current academic cycle). |
| **status** | query | string | false | Include only trainees with a particular status. Valid values are `course_not_yet_started`, `in_training`,  `deferred`, `awarded`,  `withdrawn` |
| **since** | query | string | false | Include only trainees changed or created on or since a date and time. DateTimes should be in ISO 8601 format. |
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
          "withdraw_reasons_details": null,
          "defer_date": "2023-10-17",
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
          "lead_school_not_applicable": false,
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
          "lead_partner_urn_ukprn": null,
          "lead_school_urn": null,
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
---

### `GET /trainees/{trainee_id}`

Get a single trainee.

#### Request

`GET /api/v0.1/trainees/{trainee_id}`

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
        "withdraw_reasons_details": null,
        "defer_date": "2023-10-17",
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
        "lead_school_not_applicable": false,
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
        "lead_partner_urn_ukprn": null,
        "lead_school_urn": null,
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
            "school_id": 26214,
            "urn": "123456",
            "name": "Meadow Creek School",
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

### `GET /trainees/{trainee_id}/placements`

Get many placements for a trainee.

#### Request

`GET /api/v0.1/trainees/{trainee_id}/placements`

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

### `GET /trainees/{trainee_id}/placements/{placement_id}`

Get a single placement for a trainee.

#### Request

`GET /api/v0.1/trainees/{trainee_id}/placements/{placement_id}`

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

### `GET /trainees/{trainee_id}/degrees`

Get many degrees for a trainee.

#### Request

`GET /api/v0.1/trainees/{trainee_id}/degrees`

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

### `GET /trainees/{trainee_id}/degrees/{degree_id}`

Get a single degree for a trainee.

#### Request

`GET /api/v0.1/trainees/{trainee_id}/degrees/{degree_id}`

#### Parameters

| **Parameter**	 | **In**  | **Type** | **Required** | **Description** 				|
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

### `POST /trainees`

Create a trainee.

#### Request

`POST /api/v0.1/trainees`

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
        "provider_trainee_id": "12345678",
        "first_names": "John",
        "last_name": "Doe",
        "date_of_birth": "1990-01-01",
        "sex": "11",
        "email": "john.doe@example.com",
        "training_route": "11",
        "itt_start_date": "2023-09-01",
        "itt_end_date": "2024-07-01",
        "course_subject_one": "100425",
        "study_mode": "01",
        "nationality": "GB",
        "ethnicity": "120",
        "disability1": "58",
        "itt_aim": "201",
        "itt_qualification_aim": "004",
        "course_year": "2",
        "course_age_range": "13918",
        "fund_code": "7",
        "funding_method": "4",
        "hesa_id": "1210007145123456",
        "placements_attributes": [
          {
            "urn": "123456",
            "name": "Placement"
          }
        ],
        "degrees_attributes": [
          {
            "grade": "02",
            "subject": "100425",
            "institution": "0116",
            "uk_degree": "083",
            "graduation_year": "2012-07-31"
          }
        ]
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
        "withdraw_reasons_details": null,
        "defer_date": "2023-10-17",
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
        "lead_school_not_applicable": false,
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
        "lead_partner_urn_ukprn": null,
        "lead_school_urn": null,
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
            "school_id": 26214,
            "urn": "123456",
            "name": "Meadow Creek School",
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

---

### `POST /trainees/{trainee_id}/placements`

Create a placement for this trainee.

#### Request

`POST /api/v0.1/trainees/{trainee_id}/placements`

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
        "urn": "123456",
        "name": "Placement"
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
  <summary class="govuk-details__summary">HTTP 409<span> - Conflict</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "errors": [
        {
          "error": "Conflict",
          "message": "Urn has already been taken"
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

`POST /api/v0.1/trainees/{trainee_id}/degrees`

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
        "institution": "0116",
        "uk_degree": "083",
        "graduation_year": "2012-07-31"
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

---


### `POST /trainees/{trainee_id}/withdraw`

Withdraw a trainee.

#### Request

`POST /api/v0.1/trainees/{trainee_id}/withdraw?reasons[]={reasons}&withdraw_date={withdraw_date}&withdraw_reasons_details={withdraw_reasons_details}&withdraw_reasons_dfe_details={withdraw_reasons_dfe_details}`

There is no request body for this endpoint.

#### Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |
| **reasons** | query | array of strings | true | The reason(s) for the withdrawal |
| **withdraw_date** | query | string | true | The date and time of the withdrawal in ISO 8601 format |
| **withdraw_reasons_details** | query | string | false | Details about why the trainee withdrew |
| **withdraw_reasons_dfe_details** | query | string | false | What the Department of Education could have done to prevent the trainee withdrawing |

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
        "withdraw_reasons_details": null,
        "defer_date": "2023-10-17",
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
        "lead_school_not_applicable": false,
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
        "lead_partner_urn_ukprn": null,
        "lead_school_urn": null,
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
            "school_id": 26214,
            "urn": "123456",
            "name": "Meadow Creek School",
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

`DELETE /api/v0.1/trainees/{trainee_id}/degrees/{degree_id}`

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
        "withdraw_reasons_details": null,
        "defer_date": "2023-10-17",
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
        "lead_school_not_applicable": false,
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
        "lead_partner_urn_ukprn": null,
        "lead_school_urn": null,
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
            "school_id": 26214,
            "urn": "123456",
            "name": "Meadow Creek School",
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

### `PUT|PATCH /trainees/{trainee_id}`

Updates an existing trainee.

#### Request

`PUT /api/v0.1/trainees/{trainee_id}`

or

`PATCH /api/v0.1/trainees/{trainee_id}`

#### Parameters

| **Parameter**	| **In**	| **Type** | **Required** | **Description** |
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
        "withdraw_reasons_details": null,
        "defer_date": "2023-10-17",
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
        "lead_school_not_applicable": false,
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
        "lead_partner_urn_ukprn": null,
        "lead_school_urn": null,
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
            "school_id": 26214,
            "urn": "123456",
            "name": "Meadow Creek School",
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

`PUT /api/v0.1/trainees/{trainee_id}/placements/{placement_id}`

or

`PATCH /api/v0.1/trainees/{trainee_id}/placements/{placement_id}`

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
        "trainee_id": 644065,
        "address": null,
        "name": "Wellsway School",
        "postcode": null,
        "created_at": "2024-03-19T22:23:48.619Z",
        "updated_at": "2024-03-19T22:23:48.619Z"
      }
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

`PUT /api/v0.1/trainees/{trainee_id}/degrees/{degree_id}`

or

`PATCH /api/v0.1/trainees/{trainee_id}/degrees/{degree_id}`

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
          "message": "This is a duplicate degree"
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


---

### `DELETE /trainees/{trainee_id}/placements/{placement_id}`

Deletes an existing placement for this trainee.

#### Request

`DELETE /api/v0.1/trainees/{trainee_id}/placements/{placement_id}`

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
        "withdraw_reasons_details": null,
        "defer_date": "2023-10-17",
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
        "lead_school_not_applicable": false,
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
        "lead_partner_urn_ukprn": null,
        "lead_school_urn": null,
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
            "school_id": 26214,
            "urn": "123456",
            "name": "Meadow Creek School",
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

### `DELETE /trainees/{trainee_id}/degrees/{degree_id}`

Deletes an existing degree for this trainee.

#### Request

`DELETE /api/v0.1/trainees/{trainee_id}/degrees/{degree_id}`

#### Parameters

| **Parameter**	| **In**	| **Type** | **Required** | **Description** |
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
        The unique ID of the trainee in the Provider's student record system (SRS). Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/ownstu">HESA provider's own identifier for student field</a>
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
        string (limited to 10 characters)
      </p>
      <p class="govuk-body">
        The unique ID of the application in the Apply system.
      </p>
      <p class="govuk-body">
        Example: <code>11fc0d3b2f</code>
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
        The date of birth of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/birthdte">HESA date of birth field</a>
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
        The sex of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/sexid">HESA sex identifier field</a>
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
        string (limited to 2 characters), required
      </p>
      <p class="govuk-body">
        The nationality of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/nation">HESA nationality field</a>
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
        The email address of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/nqtemail">HESA email addresses field</a>
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
        The ethnicity of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/ethnic">HESA ethnicity field</a>. The values for <code>ethnic_background</code> and <code>ethnic_group</code> will be set based on the <code>ethnicity</code> value.
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
        The type of disabilities that the trainee has. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/disable">HESA disability field</a>
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
        The general qualification aim of the course in terms of qualifications and professional statuses. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/ittaim">HESA ITT qualification aim field</a>
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
        The training route that the trainee is on. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/entryrte">HESA entry route field</a>
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
        string (limited to 3 characters), required
      </p>
      <p class="govuk-body">
        The qualification aim of the trainee's course. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/qlaim">HESA qualification aim field</a>
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
        The subjects included in the trainee's course. The first subject is the main one. It represents the bursary or scholarship available if applicable. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/sbjca">HESA subject of ITT course field</a>
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
        This indicates whether the trainee's course is full time or part time. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/mode">HESA mode of study field</a>
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
        The year number of the course that the trainee is currently studying. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/yearprg">HESA year of course field</a>
      </p>
      <p class="govuk-body">
        Example: <code>2</code>
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
        The age range of the course. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/ittphsc">HESA ITT phase/scope field</a>
      </p>
      <p class="govuk-body">
        Example: <code>13918</code>
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
        The start date of a trainee's postgraduate teaching apprenticeship. Dates should be in ISO 8601 format.
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
    <dt class="govuk-summary-list__key"><code>lead_school_urn</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 6 characters)
      </p>
      <p class="govuk-body">
        The Unique Reference Number (URN) of the lead school for School Direct trainees.
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
        The funding eligibility of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/fundcode">HESA fundability code field</a>
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
        The bursary level awarded to the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/burslev">HESA bursary level award field</a>
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
        The main training initiative that the trainee is on. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/initiatives">HESA initiatives field</a>
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
        The secondary training initiative that the trainee is on. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/initiatives">HESA initiatives field</a>
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
        The HESA unique student identifier for the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/husid">HESA unique student identifier field</a>
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
        The trainee's National Insurance Number.
      </p>
      <p class="govuk-body">
        Example: <code>BX5867459C</code>
      </p>
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
        The URN of the school. Coded according to <a href="https://www.hesa.ac.uk/collection/c23053/e/plmntsch">HESA placement school field</a>
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
        The country where the degree was awarded. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/degctry">HESA degree country field</a>
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
        The grade of the degree. Coded according to <a href="https://www.hesa.ac.uk/collection/c23053/e/degclss">HESA degree class field</a>
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
        The type of UK degree. Coded according to <a href="https://www.hesa.ac.uk/collection/c23053/e/degtype">HESA degree type field</a>
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
        string, required if degree is <strong>not</strong> from the UK
      </p>
      <p class="govuk-body">
        The UK ENIC comparable degree type for non-UK degrees.
      </p>
      <p class="govuk-body">
        Example: <code>Ordinary bachelor degree</code>
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
        The degree subject. Coded according to <a href="https://www.hesa.ac.uk/collection/c23053/e/degsbj">HESA degree subject field</a>
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
        The awarding institution. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/degest">HESA degree establishment field</a>
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
        The year of graduation. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/degenddt">HESA degree end date field</a>
      </p>
      <p class="govuk-body">
        Example: <code>2012-07-31</code>
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
      <th scope="row" class="govuk-table__header">Trainee.properties.application_id.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">10</td>
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
      <th scope="row" class="govuk-table__header">Trainee.properties.lead_school_urn.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">6</td>
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
      <th scope="row" class="govuk-table__header">Degree.properties.subject.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">6</td>
    </tr>
    <tr class="govuk-table__row">
      <th scope="row" class="govuk-table__header">Degree.properties.institution.maxLength</th>
      <td class="govuk-table__cell govuk-table__cell--numeric">4</td>
    </tr>
  </tbody>
</table>
