This API allows you to access information about trainees and provides endpoints to update and create trainee data.

## Contents

- [API versioning strategy](#api-versioning-strategy)
- [Draft version 0.1](#draft-version-0-1)
- [Developing on the API](#developing-on-the-api)
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
    - [PUT|PATCH /trainees/{trainee_id}/{trainee_id}](#code-put-patch-trainees-trainee_id-trainee_id-code)
    - [PUT|PATCH /trainees/{trainee_id}/placements/{placement_id}](#code-put-patch-trainees-trainee_id-placements-placement_id-code)
    - [PUT|PATCH /trainees/{trainee_id}/degrees/{degree_id}](#code-put-patch-trainees-trainee_id-degrees-degree_id-code)
    - [DELETE /trainees/{trainee_id}/placements/{placement_id}](#code-delete-trainees-trainee_id-placements-placement_id-code)
    - [DELETE /trainees/{trainee_id}/degrees/{degree_id}](#code-delete-trainees-trainee_id-degrees-degree_id-code)
- [Objects](#objects)
    - [Trainee](#trainee-object)
    - [Placement](#placement-object)
    - [Degree](#degree-object)

---

## API versioning strategy

Find out about [how we make updates to the API](/api-docs#api-versioning-strategy), including:

- the difference between breaking and non-breaking changes
- how the API version number reflects changes
- using the correct version of the API

---

## Draft version 0.1

Version 0.1 is a draft version of the API. It is not yet officially released.

It is designed for testing and feedback purposes only.

It will have some seed data to help you test the API.

It will only be available on the `sandbox` environment.

---

## Developing on the API

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
| **status** | query | string | false | Include only trainees with a particular status. Valid values are `draft`, `submitted_for_trn`, `trn_received`, `recommended_for_award`, `withdrawn`, `deferred`, `awarded` |
| **since** | query | string | false | Include only trainees changed or created on or since a date. Dates should be in ISO 8601 format. |
| **page** | query | integer | false | Page number (defaults to 1, the first page). |
| **per_page** | query | integer | false | Number of records to return per page (default is 50) |
| **sort_by** | query | string | false | Sort in ascending or descending order. Valid values are `asc` or `desc` (default is `desc`) |

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
          "dttp_id": null,
          "middle_names": null,
          "training_route": "provider_led_postgrad",
          "sex": "female",
          "diversity_disclosure": "diversity_disclosed",
          "ethnic_group": "mixed_ethnic_group",
          "ethnic_background": "Another Mixed background",
          "additional_ethnic_background": null,
          "disability_disclosure": "no_disability",
          "course_subject_one": "primary teaching",
          "itt_start_date": "2023-09-04",
          "progress": {
            "personal_details": false,
            "contact_details": false,
            "degrees": false,
            "placements": false,
            "diversity": false,
            "course_details": false,
            "training_details": false,
            "trainee_start_status": false,
            "trainee_data": false,
            "schools": false,
            "funding": false,
            "iqts_country": false,
            "placement_details": false
          },
          "provider_id": 30,
          "outcome_date": null,
          "itt_end_date": "2023-10-17",
          "placement_assignment_dttp_id": null,
          "trn": "6440650",
          "submitted_for_trn_at": "2024-01-18T08:02:41.420Z",
          "status": "deferred",
          "withdraw_date": null,
          "withdraw_reasons_details": null,
          "defer_date": "2023-10-17",
          "recommended_for_award_at": null,
          "dttp_update_sha": null,
          "trainee_start_date": "2023-09-04",
          "reinstate_date": null,
          "dormancy_dttp_id": null,
          "lead_school_id": null,
          "employing_school_id": null,
          "apply_application_id": null,
          "course_min_age": 5,
          "course_max_age": 11,
          "course_subject_two": null,
          "course_subject_three": null,
          "awarded_at": null,
          "training_initiative": "no_initiative",
          "applying_for_bursary": false,
          "bursary_tier": null,
          "study_mode": "full_time",
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
          "hesa_id": "87960005710003282",
          "additional_dttp_data": null,
          "created_from_hesa": true,
          "hesa_updated_at": "2024-01-17T13:49:59.000Z",
          "course_allocation_subject_id": 21,
          "start_academic_cycle_id": 15,
          "end_academic_cycle_id": 15,
          "record_source": "hesa_collection",
          "hesa_trn_submission_id": 910,
          "iqts_country": null,
          "hesa_editable": false,
          "withdraw_reasons_dfe_details": null,
          "slug_sent_to_dqt_at": "2023-10-20T14:55:02.636Z",
          "placement_detail": null,
          "application_choice_id": 452774
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
          "dttp_id": null,
          "middle_names": null,
          "training_route": "provider_led_postgrad",
          "sex": "female",
          "diversity_disclosure": "diversity_disclosed",
          "ethnic_group": "mixed_ethnic_group",
          "ethnic_background": "Another Mixed background",
          "additional_ethnic_background": null,
          "disability_disclosure": "no_disability",
          "course_subject_one": "primary teaching",
          "itt_start_date": "2023-09-04",
          "progress": {
            "personal_details": false,
            "contact_details": false,
            "degrees": false,
            "placements": false,
            "diversity": false,
            "course_details": false,
            "training_details": false,
            "trainee_start_status": false,
            "trainee_data": false,
            "schools": false,
            "funding": false,
            "iqts_country": false,
            "placement_details": false
          },
          "provider_id": 30,
          "outcome_date": null,
          "itt_end_date": "2023-10-17",
          "placement_assignment_dttp_id": null,
          "trn": "6440650",
          "submitted_for_trn_at": "2024-01-18T08:02:41.420Z",
          "status": "deferred",
          "withdraw_date": null,
          "withdraw_reasons_details": null,
          "defer_date": "2023-10-17",
          "recommended_for_award_at": null,
          "dttp_update_sha": null,
          "trainee_start_date": "2023-09-04",
          "reinstate_date": null,
          "dormancy_dttp_id": null,
          "lead_school_id": null,
          "employing_school_id": null,
          "apply_application_id": null,
          "course_min_age": 5,
          "course_max_age": 11,
          "course_subject_two": null,
          "course_subject_three": null,
          "awarded_at": null,
          "training_initiative": "no_initiative",
          "applying_for_bursary": false,
          "bursary_tier": null,
          "study_mode": "full_time",
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
          "hesa_id": "87960005710003282",
          "additional_dttp_data": null,
          "created_from_hesa": true,
          "hesa_updated_at": "2024-01-17T13:49:59.000Z",
          "course_allocation_subject_id": 21,
          "start_academic_cycle_id": 15,
          "end_academic_cycle_id": 15,
          "record_source": "hesa_collection",
          "hesa_trn_submission_id": 910,
          "iqts_country": null,
          "hesa_editable": false,
          "withdraw_reasons_dfe_details": null,
          "slug_sent_to_dqt_at": "2023-10-20T14:55:02.636Z",
          "placement_detail": null,
          "application_choice_id": 452774,
          "placements": [
            {
              "placement_id": "AXsRAS4LfwZZXvSX7aAfNUb4",
              "school_id": 26214,
              "urn": null,
              "name": null,
              "address": null,
              "postcode": null,
              "created_at": "2024-01-18T08:02:42.672Z",
              "updated_at": "2024-01-18T08:02:42.672Z"
            }
          ],
          "degrees": [
            {
              "degree_id": "E1phsAcP3hDFMhx19qVGhchR",
              "locale_code": "uk",
              "uk_degree": "Bachelor of Arts",
              "non_uk_degree": null,
              "created_at": "2024-01-18T08:02:41.955Z",
              "updated_at": "2024-01-18T08:02:41.955Z",
              "subject": "Childhood studies",
              "institution": "University of Bristol",
              "graduation_year": 2022,
              "grade": "Upper second-class honours (2:1)",
              "country": null,
              "other_grade": null,
              "institution_uuid": "0271f34a-2887-e711-80d8-005056ac45bb",
              "uk_degree_uuid": "db695652-c197-e711-80d8-005056ac45bb",
              "subject_uuid": "bf8170f0-5dce-e911-a985-000d3ab79618",
              "grade_uuid": "e2fe18d4-8655-47cf-ab1a-8c3e0b0f078f"
            }
          ]
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
          "placement_id": "WQsRAS4LfwZZXvSX7aAfNUx3",
          "school_id": 26214,
          "urn": null,
          "name": null,
          "address": null,
          "postcode": null,
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
      "data": [
        {
          "placement_id": "WQsRAS4LfwZZXvSX7aAfNUx3",
          "school_id": 26214,
          "urn": null,
          "name": null,
          "address": null,
          "postcode": null,
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
          "locale_code": "uk",
          "uk_degree": "Bachelor of Arts",
          "non_uk_degree": null,
          "created_at": "2024-01-18T08:02:41.955Z",
          "updated_at": "2024-01-18T08:02:41.955Z",
          "subject": "Childhood studies",
          "institution": "University of Bristol",
          "graduation_year": 2022,
          "grade": "Upper second-class honours (2:1)",
          "country": null,
          "other_grade": null,
          "dttp_id": null,
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
      "data": [
        {
          "id": 270180,
          "trainee_id": 644065,
          "school_id": 26214,
          "urn": null,
          "name": null,
          "address": null,
          "postcode": null,
          "created_at": "2024-01-18T08:02:42.672Z",
          "updated_at": "2024-01-18T08:02:42.672Z",
          "slug": "WQsRAS4LfwZZXvSX7aAfNUx3"
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

### `POST /trainees`

Create a trainee.

#### Request

`PUT /api/v0.1/trainees/{trainee_id}/{trainee_id}`

or

`PATCH /api/v0.1/trainees/{trainee_id}/{trainee_id}`

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
        "first_names": "John",
        "middle_names": "James",
        "last_name": "Doe",
        "date_of_birth": "1990-01-01",
        "sex": "male",
        "email": "john.doe@example.com",
        "trn": "123456",
        "training_route": "assessment_only",
        "itt_start_date": "2022-09-01",
        "itt_end_date": "2023-07-01",
        "diversity_disclosure": "diversity_disclosed",
        "ethnic_group": "white_ethnic_group",
        "ethnic_background": "Background 1",
        "disability_disclosure": "no_disability",
        "course_subject_one": "Maths",
        "course_subject_two": "Science",
        "course_subject_three": "English",
        "study_mode": "full_time",
        "application_choice_id": "123",
        "placements_attributes": [{ "urn": "123456", "name": "Placement" }],
        "degrees_attributes": [{ "country": "UK", "grade": "First", "subject": "Computer Science", "institution": "University of Test", "graduation_year": "2012", "locale_code": "uk" }]
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
      "data": [
        {
          "trainee_id": "vcGjpBCn987jJSqMQxjhdv9Y",
          "provider_trainee_id": "abc1234",
          "first_names": "Ruby Joy",
          "last_name": "TraineeUser644065",
          "date_of_birth": "2000-01-01",
          "created_at": "2023-10-20T14:54:47.374Z",
          "updated_at": "2024-01-24T16:03:28.721Z",
          "email": "trainee_644065@example.com",
          "dttp_id": null,
          "middle_names": "James",
          "training_route": "assessment_only",
          "sex": "male",
          "diversity_disclosure": "diversity_disclosed",
          "ethnic_group": "white_ethnic_group",
          "ethnic_background": "Background 1",
          "additional_ethnic_background": null,
          "disability_disclosure": "no_disability",
          "course_subject_one": "Maths",
          "itt_start_date": "2022-09-01",
          "progress": {
            "personal_details": true,
            "contact_details": true,
            "degrees": false,
            "placements": false,
            "diversity": true,
            "course_details": true,
            "training_details": true,
            "trainee_start_status": true,
            "trainee_data": true,
            "schools": true,
            "funding": true,
            "iqts_country": true
          },
          "provider_id": 30,
          "outcome_date": null,
          "itt_end_date": "2023-07-01",
          "placement_assignment_dttp_id": null,
          "trn": "6440650",
          "submitted_for_trn_at": "2024-01-18T08:02:41.420Z",
          "status": "deferred",
          "withdraw_date": null,
          "withdraw_reasons_details": null,
          "defer_date": "2023-10-17",
          "recommended_for_award_at": null,
          "dttp_update_sha": null,
          "trainee_start_date": null,
          "reinstate_date": null,
          "dormancy_dttp_id": null,
          "lead_school_id": null,
          "employing_school_id": null,
          "apply_application_id": null,
          "course_min_age": null,
          "course_max_age": null,
          "course_subject_two": "Science",
          "course_subject_three": "English",
          "awarded_at": null,
          "training_initiative": null,
          "applying_for_bursary": null,
          "bursary_tier": null,
          "study_mode": "full_time",
          "ebacc": false,
          "region": null,
          "applying_for_scholarship": null,
          "course_education_phase": null,
          "applying_for_grant": null,
          "course_uuid": null,
          "lead_school_not_applicable": false,
          "employing_school_not_applicable": false,
          "submission_ready": false,
          "commencement_status": null,
          "discarded_at": null,
          "created_from_dttp": false,
          "hesa_id": null,
          "additional_dttp_data": null,
          "created_from_hesa": false,
          "hesa_updated_at": null,
          "course_allocation_subject_id": null,
          "start_academic_cycle_id": 8,
          "end_academic_cycle_id": 8,
          "record_source": null,
          "hesa_trn_submission_id": null,
          "iqts_country": null,
          "hesa_editable": false,
          "withdraw_reasons_dfe_details": null,
          "slug_sent_to_dqt_at": null,
          "placement_detail": null,
          "application_choice_id": 123,
          "ukprn": "10000571",
          "ethnicity": null,
          "ethnicity_background": null,
          "other_ethnicity_details": null,
          "disability": null,
          "other_disability_details": null,
          "course_qualification": null,
          "course_title": null,
          "course_level": null,
          "course_itt_subject": null,
          "course_study_mode": null,
          "course_itt_start_date": "2022-09-01",
          "course_age_range": [],
          "expected_end_date": "2023-07-01",
          "employing_school_urn": null,
          "lead_partner_urn_ukprn": null,
          "fund_code": null,
          "funding_option": null,
          "nationality": null,
          "placements": [
            {
              "placement_id": "AXsRAS4LfwZZXvSX7aAfNUb4",
              "school_id": 26214,
              "urn": null,
              "name": null,
              "address": null,
              "postcode": null,
              "created_at": "2024-01-18T08:02:42.672Z",
              "updated_at": "2024-01-18T08:02:42.672Z"
            }
          ],
          "degrees": [
            {
              "degree_id": "E1phsAcP3hDFMhx19qVGhchR",
              "locale_code": "uk",
              "uk_degree": null,
              "non_uk_degree": null,
              "trainee_id": 202901,
              "created_at": "2024-03-19T22:07:12.553Z",
              "updated_at": "2024-03-19T22:07:12.553Z",
              "subject": "Computer Science",
              "institution": "University of Test",
              "graduation_year": 2012,
              "grade": "First",
              "country": "UK",
              "other_grade": null,
              "dttp_id": null,
              "institution_uuid": null,
              "uk_degree_uuid": null,
              "subject_uuid": null,
              "grade_uuid": null
            }
          ]
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
        "placement_id": "BFsRAS4LfwZZXvSX7aAfNUj3",
        "address": null,
        "name": "Wellsway School",
        "postcode": null,
        "urn": "137523",
        "school_id": null,
        "id": 270180,
        "created_at": "2024-01-18T08:02:42.672Z",
        "updated_at": "2024-03-18T22:31:08.340Z"
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
        "country": "UK",
        "grade": "First",
        "subject": "Applied linguistics",
        "institution": "University of Oxford",
        "uk_degree": "Bachelor of Arts",
        "graduation_year": "2012",
        "locale_code": "uk"
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
          "locale_code": "uk",
          "uk_degree": "Bachelor of Arts",
          "non_uk_degree": null,
          "trainee_id": 644065,
          "created_at": "2024-01-18T08:02:41.955Z",
          "updated_at": "2024-01-18T08:02:41.955Z",
          "subject": "Childhood studies",
          "institution": "University of Bristol",
          "graduation_year": 2023,
          "grade": "Lower second-class honours (2:2)",
          "country": null,
          "other_grade": null,
          "dttp_id": null,
          "institution_uuid": "0271f34a-2887-e711-80d8-005056ac45bb",
          "uk_degree_uuid": "db695652-c197-e711-80d8-005056ac45bb",
          "subject_uuid": "bf8170f0-5dce-e911-a985-000d3ab79618",
          "grade_uuid": "377a46ea-d6c6-4e87-9728-c1f0dd0ef109"
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
          "message": "Request could not be parsed"
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

`POST /api/v0.1/trainees/{trainee_id}/withdraw`

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
          "dttp_id": null,
          "middle_names": null,
          "training_route": "provider_led_postgrad",
          "sex": "female",
          "diversity_disclosure": "diversity_disclosed",
          "ethnic_group": "mixed_ethnic_group",
          "ethnic_background": "Another Mixed background",
          "additional_ethnic_background": null,
          "disability_disclosure": "no_disability",
          "course_subject_one": "primary teaching",
          "itt_start_date": "2023-09-04",
          "progress": {
            "personal_details": false,
            "contact_details": false,
            "degrees": false,
            "placements": false,
            "diversity": false,
            "course_details": false,
            "training_details": false,
            "trainee_start_status": false,
            "trainee_data": false,
            "schools": false,
            "funding": false,
            "iqts_country": false,
            "placement_details": false
          },
          "provider_id": 30,
          "outcome_date": null,
          "itt_end_date": "2023-10-17",
          "placement_assignment_dttp_id": null,
          "trn": "6440650",
          "submitted_for_trn_at": "2024-01-18T08:02:41.420Z",
          "status": "deferred",
          "withdraw_date": null,
          "withdraw_reasons_details": null,
          "defer_date": "2023-10-17",
          "recommended_for_award_at": null,
          "dttp_update_sha": null,
          "trainee_start_date": "2023-09-04",
          "reinstate_date": null,
          "dormancy_dttp_id": null,
          "lead_school_id": null,
          "employing_school_id": null,
          "apply_application_id": null,
          "course_min_age": 5,
          "course_max_age": 11,
          "course_subject_two": null,
          "course_subject_three": null,
          "awarded_at": null,
          "training_initiative": "no_initiative",
          "applying_for_bursary": false,
          "bursary_tier": null,
          "study_mode": "full_time",
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
          "hesa_id": "87960005710003282",
          "additional_dttp_data": null,
          "created_from_hesa": true,
          "hesa_updated_at": "2024-01-17T13:49:59.000Z",
          "course_allocation_subject_id": 21,
          "start_academic_cycle_id": 15,
          "end_academic_cycle_id": 15,
          "record_source": "hesa_collection",
          "hesa_trn_submission_id": 910,
          "iqts_country": null,
          "hesa_editable": false,
          "withdraw_reasons_dfe_details": null,
          "slug_sent_to_dqt_at": "2023-10-20T14:55:02.636Z",
          "placement_detail": null,
          "application_choice_id": 452774,
          "placements": [
            {
              "id": 270180,
              "trainee_id": 644065,
              "school_id": 26214,
              "urn": null,
              "name": null,
              "address": null,
              "postcode": null,
              "created_at": "2024-01-18T08:02:42.672Z",
              "updated_at": "2024-01-18T08:02:42.672Z",
              "slug": "AXsRAS4LfwZZXvSX7aAfNUb4"
            }
          ],
          "degrees": [
            {
              "degree_id": "E1phsAcP3hDFMhx19qVGhchR",
              "locale_code": "uk",
              "uk_degree": "Bachelor of Arts",
              "non_uk_degree": null,
              "trainee_id": 644065,
              "created_at": "2024-01-18T08:02:41.955Z",
              "updated_at": "2024-01-18T08:02:41.955Z",
              "subject": "Childhood studies",
              "institution": "University of Bristol",
              "graduation_year": 2022,
              "grade": "Upper second-class honours (2:1)",
              "country": null,
              "other_grade": null,
              "dttp_id": null,
              "institution_uuid": "0271f34a-2887-e711-80d8-005056ac45bb",
              "uk_degree_uuid": "db695652-c197-e711-80d8-005056ac45bb",
              "subject_uuid": "bf8170f0-5dce-e911-a985-000d3ab79618",
              "grade_uuid": "e2fe18d4-8655-47cf-ab1a-8c3e0b0f078f"
            }
          ]
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

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |
| **degree_id** | path | string | true | The unique ID of the degree |

#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 404<span> - Not found</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "errors": [
        {
          "degree_id": "E1phsAcP3hDFMhx19qVGhchR",
          "locale_code": "uk",
          "uk_degree": "Bachelor of Arts",
          "non_uk_degree": null,
          "trainee_id": 644065,
          "created_at": "2024-01-18T08:02:41.955Z",
          "updated_at": "2024-01-18T08:02:41.955Z",
          "subject": "Childhood studies",
          "institution": "University of Bristol",
          "graduation_year": 2023,
          "grade": "Lower second-class honours (2:2)",
          "country": null,
          "other_grade": null,
          "dttp_id": null,
          "institution_uuid": "0271f34a-2887-e711-80d8-005056ac45bb",
          "uk_degree_uuid": "db695652-c197-e711-80d8-005056ac45bb",
          "subject_uuid": "bf8170f0-5dce-e911-a985-000d3ab79618",
          "grade_uuid": "377a46ea-d6c6-4e87-9728-c1f0dd0ef109"
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

### `PUT|PATCH /trainees/{trainee_id}/{trainee_id}`

Updates an existing trainee.

#### Request

`PUT /api/v0.1/trainees/{trainee_id}/{trainee_id}`

or

`PATCH /api/v0.1/trainees/{trainee_id}/{trainee_id}`

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
      "data": [
        {
          "trainee_id": "GJGu9X8YSewEzPuJPyNFsbes",
          "provider_trainee_id": "abc1234",
          "first_names": "John",
          "last_name": "Doe",
          "date_of_birth": "1990-01-01",
          "created_at": "2024-03-19T22:07:12.529Z",
          "updated_at": "2024-03-19T22:07:12.561Z",
          "email": "john.doe@example.com",
          "dttp_id": null,
          "middle_names": "James",
          "training_route": "assessment_only",
          "sex": "male",
          "diversity_disclosure": "diversity_disclosed",
          "ethnic_group": "white_ethnic_group",
          "ethnic_background": "Background 1",
          "additional_ethnic_background": null,
          "disability_disclosure": "no_disability",
          "course_subject_one": "primary teaching",
          "itt_start_date": "2023-09-04",
          "progress": {
            "personal_details": false,
            "contact_details": false,
            "degrees": false,
            "placements": false,
            "diversity": false,
            "course_details": false,
            "training_details": false,
            "trainee_start_status": false,
            "trainee_data": false,
            "schools": false,
            "funding": false,
            "iqts_country": false,
            "placement_details": false
          },
          "provider_id": 30,
          "outcome_date": null,
          "itt_end_date": "2023-10-17",
          "placement_assignment_dttp_id": null,
          "trn": "6440650",
          "submitted_for_trn_at": "2024-01-18T08:02:41.420Z",
          "state": "deferred",
          "withdraw_date": null,
          "withdraw_reasons_details": null,
          "defer_date": null,
          "recommended_for_award_at": null,
          "dttp_update_sha": null,
          "trainee_start_date": "2023-09-04",
          "reinstate_date": null,
          "dormancy_dttp_id": null,
          "lead_school_id": null,
          "employing_school_id": null,
          "apply_application_id": null,
          "course_min_age": 5,
          "course_max_age": 11,
          "course_subject_two": null,
          "course_subject_three": null,
          "awarded_at": null,
          "training_initiative": "no_initiative",
          "applying_for_bursary": false,
          "bursary_tier": null,
          "study_mode": "full_time",
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
          "hesa_id": "87960005710003282",
          "additional_dttp_data": null,
          "created_from_hesa": true,
          "hesa_updated_at": "2024-01-17T13:49:59.000Z",
          "course_allocation_subject_id": 21,
          "start_academic_cycle_id": 15,
          "end_academic_cycle_id": 15,
          "record_source": "hesa_collection",
          "hesa_trn_submission_id": 910,
          "iqts_country": null,
          "hesa_editable": false,
          "withdraw_reasons_dfe_details": null,
          "slug_sent_to_dqt_at": "2023-10-20T14:55:02.636Z",
          "placement_detail": null,
          "application_choice_id": 452774,
          "placements": [
            {
              "placement_id": "BWUDxpWVqdFeeMVcnmVY1s67",
              "school_id": null,
              "urn": "123456",
              "name": "Placement",
              "address": null,
              "postcode": null,
              "created_at": "2024-03-19T22:07:12.572Z",
              "updated_at": "2024-03-19T22:07:12.572Z"
            }
          ],
          "degrees": [
            {
              "degree_id": "W98C6yWChUwhFSEsN5idGgCx",
              "locale_code": "uk",
              "uk_degree": null,
              "non_uk_degree": null,
              "created_at": "2024-03-19T22:07:12.553Z",
              "updated_at": "2024-03-19T22:07:12.553Z",
              "subject": "Computer Science",
              "institution": "University of Test",
              "graduation_year": 2012,
              "grade": "First",
              "country": "UK",
              "other_grade": null,
              "dttp_id": null,
              "institution_uuid": "0271f34a-2887-e711-80d8-005056ac45bb",
              "uk_degree_uuid": "db695652-c197-e711-80d8-005056ac45bb",
              "subject_uuid": "bf8170f0-5dce-e911-a985-000d3ab79618",
              "grade_uuid": "e2fe18d4-8655-47cf-ab1a-8c3e0b0f078f"
            }
          ]
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

<details class="govuk-details">
  <summary class="govuk-details__summary">HTTP 422<span> - Unprocessable Entity</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "errors": [
        {
          "error": "UnprocessableEntity",
          "message": "First names is too long (maximum is 50 characters)"
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
        "placement_id": "4QVvufb2UJM1gdhKnsyKiVkj",
        "school_id": null,
        "urn": "123456",
        "name": "Placement",
        "address": null,
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
        "graduation_year": 2022,
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
        "degree_id": "vxAnSsSM91Ys2NhLYS8MC2CL",
        "locale_code": "uk",
        "uk_degree": "Bachelor of Arts",
        "non_uk_degree": null,
        "created_at": "2024-03-20T12:23:23.092Z",
        "updated_at": "2024-03-20T12:23:23.092Z",
        "subject": "Applied linguistics",
        "institution": "University of Oxford",
        "graduation_year": 2012,
        "grade": "First",
        "country": "UK",
        "other_grade": null,
        "dttp_id": null,
        "institution_uuid": null,
        "uk_degree_uuid": null,
        "subject_uuid": null,
        "grade_uuid": null
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
          "dttp_id": null,
          "middle_names": null,
          "training_route": "provider_led_postgrad",
          "sex": "female",
          "diversity_disclosure": "diversity_disclosed",
          "ethnic_group": "mixed_ethnic_group",
          "ethnic_background": "Another Mixed background",
          "additional_ethnic_background": null,
          "disability_disclosure": "no_disability",
          "course_subject_one": "primary teaching",
          "itt_start_date": "2023-09-04",
          "progress": {
            "personal_details": false,
            "contact_details": false,
            "degrees": false,
            "placements": false,
            "diversity": false,
            "course_details": false,
            "training_details": false,
            "trainee_start_status": false,
            "trainee_data": false,
            "schools": false,
            "funding": false,
            "iqts_country": false,
            "placement_details": false
          },
          "provider_id": 30,
          "outcome_date": null,
          "itt_end_date": "2023-10-17",
          "placement_assignment_dttp_id": null,
          "trn": "6440650",
          "submitted_for_trn_at": "2024-01-18T08:02:41.420Z",
          "state": "deferred",
          "withdraw_date": null,
          "withdraw_reasons_details": null,
          "defer_date": "2023-10-17",
          "recommended_for_award_at": null,
          "dttp_update_sha": null,
          "trainee_start_date": "2023-09-04",
          "reinstate_date": null,
          "dormancy_dttp_id": null,
          "lead_school_id": null,
          "employing_school_id": null,
          "apply_application_id": null,
          "course_min_age": 5,
          "course_max_age": 11,
          "course_subject_two": null,
          "course_subject_three": null,
          "awarded_at": null,
          "training_initiative": "no_initiative",
          "applying_for_bursary": false,
          "bursary_tier": null,
          "study_mode": "full_time",
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
          "hesa_id": "87960005710003282",
          "additional_dttp_data": null,
          "created_from_hesa": true,
          "hesa_updated_at": "2024-01-17T13:49:59.000Z",
          "course_allocation_subject_id": 21,
          "start_academic_cycle_id": 15,
          "end_academic_cycle_id": 15,
          "record_source": "hesa_collection",
          "hesa_trn_submission_id": 910,
          "iqts_country": null,
          "hesa_editable": false,
          "withdraw_reasons_dfe_details": null,
          "slug_sent_to_dqt_at": "2023-10-20T14:55:02.636Z",
          "placement_detail": null,
          "application_choice_id": 452774,
          "placements": [
            {
              "placement_id": "AXsRAS4LfwZZXvSX7aAfNUb4",
              "school_id": 26214,
              "urn": null,
              "name": null,
              "address": null,
              "postcode": null,
              "created_at": "2024-01-18T08:02:42.672Z",
              "updated_at": "2024-01-18T08:02:42.672Z"
            }
          ],
          "degrees": [
            {
              "degree_id": "E1phsAcP3hDFMhx19qVGhchR",
              "locale_code": "uk",
              "uk_degree": "Bachelor of Arts",
              "non_uk_degree": null,
              "created_at": "2024-01-18T08:02:41.955Z",
              "updated_at": "2024-01-18T08:02:41.955Z",
              "subject": "Childhood studies",
              "institution": "University of Bristol",
              "graduation_year": 2022,
              "grade": "Upper second-class honours (2:1)",
              "country": null,
              "other_grade": null,
              "dttp_id": null,
              "institution_uuid": "0271f34a-2887-e711-80d8-005056ac45bb",
              "uk_degree_uuid": "db695652-c197-e711-80d8-005056ac45bb",
              "subject_uuid": "bf8170f0-5dce-e911-a985-000d3ab79618",
              "grade_uuid": "e2fe18d4-8655-47cf-ab1a-8c3e0b0f078f"
            }
          ]
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
          "id": 492440,
          "locale_code": "uk",
          "uk_degree": "Bachelor of Arts",
          "non_uk_degree": null,
          "trainee_id": 644065,
          "created_at": "2024-01-18T08:02:41.955Z",
          "updated_at": "2024-01-18T08:02:41.955Z",
          "subject": "Childhood studies",
          "institution": "University of Bristol",
          "graduation_year": 2023,
          "grade": "Lower second-class honours (2:2)",
          "country": null,
          "other_grade": null,
          "slug": "E1phsAcP3hDFMhx19qVGhchR",
          "dttp_id": null,
          "institution_uuid": "0271f34a-2887-e711-80d8-005056ac45bb",
          "uk_degree_uuid": "db695652-c197-e711-80d8-005056ac45bb",
          "subject_uuid": "bf8170f0-5dce-e911-a985-000d3ab79618",
          "grade_uuid": "377a46ea-d6c6-4e87-9728-c1f0dd0ef109"
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
        string
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
        string
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
        string
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
        string, required
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
        string, required
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
    <dt class="govuk-summary-list__key"><code>previous_surname</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string
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
        string, required
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
        string, required
      </p>
      <p class="govuk-body">
        The nationality of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/nation">HESA nationality field</a>
      </p>
      <p class="govuk-body">
        Example: <code>US</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>email</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string, required
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
        string
      </p>
      <p class="govuk-body">
        The ethnicity of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c23053/e/ethnic">HESA ethnicity field</a>
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
        string
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
        string, required
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
        string, required
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
        string, required
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
        string, <code>course_subject_one</code> is required
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
        string, required
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
    <dt class="govuk-summary-list__key"><code>year_of_course</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string, required
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
        string, required
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
        string
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
        string
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
        string, required
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
        string, required
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
        string
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
        string
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
        string, required
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
        string
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
    <dt class="govuk-summary-list__key"><code>urn</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string
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
        string
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
        string
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
        string
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
    <dt class="govuk-summary-list__key"><code>locale_code</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string, required
      </p>
      <p class="govuk-body">
        Whether the degree was awarded in the UK or not.
      </p>
      <p class="govuk-body">
        Example: <code>uk</code>
      </p>
      <p class="govuk-body">Possible values:</p>
      <ul class="govuk-list govuk-list--bullet">
        <li><code>uk</code></li>
        <li><code>non_uk</code></li>
      </ul>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>uk_degree</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string, required if <code>locale_code</code> is <code>uk</code>
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
        string, required if <code>locale_code</code> is <code>non_uk</code>
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
        string, required
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
        string, required if <code>locale_code</code> is <code>uk</code>
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
        Example: <code>2012-06-30</code>
      </p>
    </dd>
  </div>
</dl>
