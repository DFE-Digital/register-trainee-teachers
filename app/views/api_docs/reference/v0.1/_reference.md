This API allows you to access information about trainees and provides endpoints to update and create trainee data.

## Contents

- [API versioning strategy](#api-versioning-strategy)
- [Draft version 0.1](#draft-version-0-1)
- [Developing on the API](#developing-on-the-api)
- [Endpoints](#endpoints)
    - [`GET /info`](#code-get-info-code)
    - [`GET /trainees`](#code-get-trainees-code)
    - [`GET /trainees/{trainee_id}`](#code-get-trainees-trainee_id-code)
    - [`GET /trainees/{trainee_id}/placements`](#code-get-trainees-trainee_id-placements-code)
    - [`GET /trainees/{trainee_id}/placements/{placement_id}`](#code-get-trainees-trainee_id-placements-placement_id-code)
    - [`GET /trainees/{trainee_id}/degrees`](#code-get-trainees-trainee_id-degrees-code)
    - [`POST /trainees`](#code-post-trainees-code)
    - [`POST /trainees/{trainee_id}/placements`](#code-post-trainees-trainee_id-placements-code)
    - [`POST /trainees/{trainee_id}/degrees`](#code-post-trainees-trainee_id-degrees-code)
    - [`POST /trainees/{trainee_id}/withdraw`](#code-post-trainees-trainee_id-withdraw-code)
    - [`PUT|PATCH /trainees/{trainee_id}/{trainee_id}`](#code-put-patch-trainees-trainee_id-trainee_id-code)
    - [`PUT|PATCH /trainees/{trainee_id}/placements/{placement_id}`](#code-put-patch-trainees-trainee_id-placements-placement_id-code)
    - [`PUT|PATCH /trainees/{trainee_id}/degrees/{degree_id}`](#code-put-patch-trainees-trainee_id-degrees-degree_id-code)
    - [`DELETE /trainees/{trainee_id}/placements/{placement_id}`](#code-delete-trainees-trainee_id-placements-placement_id-code)
    - [`DELETE /trainees/{trainee_id}/degrees/{degree_id}`](#code-delete-trainees-trainee_id-degrees-degree_id-code)


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
  <summary class="govuk-details__summary"><code>HTTP 200</code><span> - Information about the API status</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "status": "ok"
    }
    </pre>
  </div>
</details>

<details class="govuk-details">
  <summary class="govuk-details__summary"><code>HTTP 401</code><span> - Unauthorized</span></summary>
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

#### Request

`GET /api/v0.1/trainees`

#### Parameters

| **Parameter**	| **In**	| **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **academic_cycle** | query | string | false | The academic cycle year |
| **status** | query | string | false | Include only trainees with a particular status. Valid values are `draft`, `submitted_for_trn`, `trn_received`, `recommended_for_award`, `withdrawn`, `deferred`, `awarded` |
| **since** | query | string | false | Include only trainees changed or created on or since a date. Dates should be in ISO 8601 format. |
| **page** | query | integer | false | Page number |
| **per_page** | query | integer | false | Number of records to return per page (default is 50) |
| **sort_by** | query | string | false | Sort in ascending or descending order. Valid values are `asc` or `desc` (default is `desc`) |

#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary"><code>HTTP 200</code><span> - An array of trainees</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": [
        {
          "id": 644065,
          "trainee_id": "trainee-644065",
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
          "slug": "vcGjpBCn987jJSqMQxjhdv9Y",
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
  <summary class="govuk-details__summary"><code>HTTP 404</code><span> - Not found</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 401</code><span> - Unauthorized</span></summary>
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

| **Parameter**	| **In**	| **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |

#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary"><code>HTTP 200</code><span> - A trainee</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": [
        {
          "id": 644065,
          "trainee_id": "trainee-644065",
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
          "slug": "vcGjpBCn987jJSqMQxjhdv9Y",
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
              "id": 492440,
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
              "slug": "E1phsAcP3hDFMhx19qVGhchR",
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
  <summary class="govuk-details__summary"><code>HTTP 404</code><span> - Not found</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 401</code><span> - Unauthorized</span></summary>
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

| **Parameter**	| **In**	| **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |

#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary"><code>HTTP 200</code><span> - An array of placements</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 404</code><span> - Not found</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 401</code><span> - Unauthorized</span></summary>
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

| **Parameter**	| **In**	| **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |
| **placement_id** | path | string | true | The unique ID of the placement |

#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary"><code>HTTP 200</code><span> - A placement</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 404</code><span> - Not found</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 401</code><span> - Unauthorized</span></summary>
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

| **Parameter**	| **In**	| **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |

#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary"><code>HTTP 200</code><span> - An array of degrees</span></summary>
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
          "graduation_year": 2022,
          "grade": "Upper second-class honours (2:1)",
          "country": null,
          "other_grade": null,
          "slug": "E1phsAcP3hDFMhx19qVGhchR",
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
  <summary class="govuk-details__summary"><code>HTTP 404</code><span> - Not found</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 401</code><span> - Unauthorized</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 201</code><span> - A trainee</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": [
        {
          "id": 202901,
          "trainee_id": null,
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
          "trn": "123456",
          "submitted_for_trn_at": null,
          "state": "draft",
          "withdraw_date": null,
          "withdraw_reasons_details": null,
          "defer_date": null,
          "slug": "GJGu9X8YSewEzPuJPyNFsbes",
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
              "id": 373781,
              "trainee_id": 202901,
              "school_id": null,
              "urn": "123456",
              "name": "Placement",
              "address": null,
              "postcode": null,
              "created_at": "2024-03-19T22:07:12.572Z",
              "updated_at": "2024-03-19T22:07:12.572Z",
              "slug": "BWUDxpWVqdFeeMVcnmVY1s67"
            }
          ],
          "degrees": [
            {
              "id": 533194,
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
              "slug": "W98C6yWChUwhFSEsN5idGgCx",
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
  <summary class="govuk-details__summary"><code>HTTP 401</code><span> - Unauthorized</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "error": "Unauthorized"
    }
    </pre>
  </div>
</details>

<details class="govuk-details">
  <summary class="govuk-details__summary"><code>HTTP 422</code><span> - Unprocessable Entity</span></summary>
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

| **Parameter**	| **In**	| **Type** | **Required** | **Description** |
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
  <summary class="govuk-details__summary"><code>HTTP 201</code><span> - A placement</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": {
        "id": 373782,
        "trainee_id": 194065,
        "school_id": null,
        "urn": "123456",
        "name": "Placement",
        "address": null,
        "postcode": null,
        "created_at": "2024-03-19T22:23:48.619Z",
        "updated_at": "2024-03-19T22:23:48.619Z",
        "slug": "4QVvufb2UJM1gdhKnsyKiVkj"
      }
    }
    </pre>
  </div>
</details>

<details class="govuk-details">
  <summary class="govuk-details__summary"><code>HTTP 401</code><span> - Unauthorized</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "error": "Unauthorized"
    }
    </pre>
  </div>
</details>

<details class="govuk-details">
  <summary class="govuk-details__summary"><code>HTTP 404</code><span> - Not found</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 409</code><span> - Conflict</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 422</code><span> - Unprocessable Entity</span></summary>
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

| **Parameter**	| **In**	| **Type** | **Required** | **Description** |
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
  <summary class="govuk-details__summary"><code>HTTP 201</code><span> - A degree</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": {
        "id": 533195,
        "locale_code": "uk",
        "uk_degree": "Bachelor of Arts",
        "non_uk_degree": null,
        "trainee_id": 194065,
        "created_at": "2024-03-20T12:23:23.092Z",
        "updated_at": "2024-03-20T12:23:23.092Z",
        "subject": "Applied linguistics",
        "institution": "University of Oxford",
        "graduation_year": 2012,
        "grade": "First",
        "country": "UK",
        "other_grade": null,
        "slug": "vxAnSsSM91Ys2NhLYS8MC2CL",
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
  <summary class="govuk-details__summary"><code>HTTP 401</code><span> - Unauthorized</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "error": "Unauthorized"
    }
    </pre>
  </div>
</details>

<details class="govuk-details">
  <summary class="govuk-details__summary"><code>HTTP 404</code><span> - Not found</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 409</code><span> - Conflict</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 422</code><span> - Unprocessable Entity</span></summary>
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

| **Parameter**	| **In**	| **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |
| **reasons** | query | array of strings | true | The reason(s) for the withdrawal |
| **withdraw_date** | query | string | true | The date and time of the withdrawal in ISO 8601 format |
| **withdraw_reasons_details** | query | string | false | Details about why the trainee withdrew |
| **withdraw_reasons_dfe_details** | query | string | false | What the Department of Education could have done to prevent the trainee withdrawing |

#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary"><code>HTTP 200</code><span> - A trainee</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": [
        {
          "id": 644065,
          "trainee_id": "trainee-644065",
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
          "state": "withdrawn",
          "withdraw_date": "2024-02-15T15:17:09.000Z",
          "withdraw_reasons_details": null,
          "defer_date": "2023-10-17",
          "slug": "vcGjpBCn987jJSqMQxjhdv9Y",
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
              "id": 492440,
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
              "slug": "E1phsAcP3hDFMhx19qVGhchR",
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
  <summary class="govuk-details__summary"><code>HTTP 401</code><span> - Unauthorized</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "error": "Unauthorized"
    }
    </pre>
  </div>
</details>

<details class="govuk-details">
  <summary class="govuk-details__summary"><code>HTTP 404</code><span> - Not found</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 422</code><span> - Unprocessable Entity</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 200</code><span> - A trainee</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": [
        {
          "id": 644065,
          "trainee_id": "trainee-644065",
          "first_names": "Ruby Joy",
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
          "slug": "vcGjpBCn987jJSqMQxjhdv9Y",
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
              "id": 492440,
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
              "slug": "E1phsAcP3hDFMhx19qVGhchR",
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
  <summary class="govuk-details__summary"><code>HTTP 404</code><span> - Not found</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 401</code><span> - Unauthorized</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "error": "Unauthorized"
    }
    </pre>
  </div>
</details>

<details class="govuk-details">
  <summary class="govuk-details__summary"><code>HTTP 422</code><span> - Unprocessable Entity</span></summary>
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

| **Parameter**	| **In**	| **Type** | **Required** | **Description** |
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
  <summary class="govuk-details__summary"><code>HTTP 200</code><span> - A placement</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": {
        "trainee_id": 644065,
        "address": null,
        "name": "Wellsway School",
        "postcode": null,
        "urn": "137523",
        "school_id": null,
        "id": 270180,
        "created_at": "2024-01-18T08:02:42.672Z",
        "updated_at": "2024-03-18T22:31:08.340Z",
        "slug": "BFsRAS4LfwZZXvSX7aAfNUj3"
      }
    }
    </pre>
  </div>
</details>

<details class="govuk-details">
  <summary class="govuk-details__summary"><code>HTTP 404</code><span> - Not found</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 401</code><span> - Unauthorized</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "error": "Unauthorized"
    }
    </pre>
  </div>
</details>

<details class="govuk-details">
  <summary class="govuk-details__summary"><code>HTTP 422</code><span> - Unprocessable Entity</span></summary>
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

| **Parameter**	| **In**	| **Type** | **Required** | **Description** |
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
  <summary class="govuk-details__summary"><code>HTTP 200</code><span> - A degree</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 404</code><span> - Not found</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 401</code><span> - Unauthorized</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "error": "Unauthorized"
    }
    </pre>
  </div>
</details>

<details class="govuk-details">
  <summary class="govuk-details__summary"><code>HTTP 409</code><span> - Conflict</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 422</code><span> - Unprocessable Entity</span></summary>
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

| **Parameter**	| **In**	| **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |
| **placement_id** | path | string | true | The unique ID of the placement |

#### Possible responses

<details class="govuk-details">
  <summary class="govuk-details__summary"><code>HTTP 200</code><span> - A trainee</span></summary>
  <div class="govuk-details__text">
    <pre class="json-code-sample">
    {
      "data": [
        {
          "id": 644065,
          "trainee_id": "trainee-644065",
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
          "slug": "vcGjpBCn987jJSqMQxjhdv9Y",
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
          "placements": null,
          "degrees": [
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
              "graduation_year": 2022,
              "grade": "Upper second-class honours (2:1)",
              "country": null,
              "other_grade": null,
              "slug": "E1phsAcP3hDFMhx19qVGhchR",
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
  <summary class="govuk-details__summary"><code>HTTP 404</code><span> - Not found</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 401</code><span> - Unauthorized</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 200</code><span> - A degree</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 404</code><span> - Not found</span></summary>
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
  <summary class="govuk-details__summary"><code>HTTP 401</code><span> - Unauthorized</span></summary>
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

### The Trainee object

<dl class="govuk-summary-list">
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
        Example: <code>"Ruby Joy"</code>
      </p>
    </dd>
  </div>
</dl>

### The Placement object


### The Degree object

