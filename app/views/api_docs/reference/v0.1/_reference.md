This API allows you to access information about trainees and provides endpoints to update and create trainee data.

## API versioning strategy

Find out about [how we make updates to the API](/api-docs#api-versioning-strategy), including:

- the difference between breaking and non-breaking changes
- how the API version number reflects changes
- using the correct version of the API

## Draft version 0.1

Version 0.1 is a draft version of the API. It is not yet officially released.

It is designed for testing and feedback purposes only.

It will only be available on the `sandbox` environment.

## Developing on the API

### Authentication

All requests must be accompanied by an `Authorization` request header (not as part of the URL) in the following format:

Authorization: Bearer {token}

Unauthenticated requests will receive an `UnauthorizedResponse` with a `401` status code.


## Endpoints

### `GET /info`

This endpoint provides general information about the API.

#### Request

`GET /api/v0.1/info`

#### Possible responses

`HTTP 200` - Information about the API status

    {
        "status": "ok"
    }

`HTTP 401` - Unauthorized

    {
        "error": "Unauthorized"
    }

---

### `GET /trainees`

This endpoint retrieves information about trainees.

#### Request

`GET /api/v0.1/trainees`

#### Possible responses

`HTTP 200` - An array of trainees

    {
        "data": [
            {
            "id": 194065,
            "trainee_id": "trainee-194065",
            "first_names": "Trainee",
            "last_name": "TraineeUser194065",
            "date_of_birth": "2000-01-01",
            "created_at": "2023-10-20T14:54:47.374Z",
            "updated_at": "2024-01-24T16:03:28.721Z",
            "email": "trainee_194065@example.com",
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
            "trn": "1940650",
            "submitted_for_trn_at": "2024-01-18T08:02:41.420Z",
            "state": "deferred",
            "withdraw_date": null,
            "withdraw_reasons_details": null,
            "defer_date": "2023-10-17",
            "slug": "weGjpBCn987jJSqMQxjhdv5Y",
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
            "hesa_id": "23100005710003282",
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
            "application_choice_id": 340774
            }
        ]
    }

`HTTP 401` - Unauthorized

    {
        "error": "Unauthorized"
    }

---

### `GET /trainees/{trainee_id}`

This endpoint retrieves information about a single trainee.

#### Request

`GET /api/v0.1/trainees/{trainee_id}`

#### Possible responses

`HTTP 200` - A trainee

    {
        "id": 194065,
        "trainee_id": "trainee-194065",
        "first_names": "Trainee",
        "last_name": "TraineeUser194065",
        "date_of_birth": "2000-01-01",
        "created_at": "2023-10-20T14:54:47.374Z",
        "updated_at": "2024-01-24T16:03:28.721Z",
        "email": "trainee_194065@example.com",
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
        "trn": "1940650",
        "submitted_for_trn_at": "2024-01-18T08:02:41.420Z",
        "state": "deferred",
        "withdraw_date": null,
        "withdraw_reasons_details": null,
        "defer_date": "2023-10-17",
        "slug": "cgKjpJCn259jJEqMbxjydv2Y",
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
        "hesa_id": "23100005710003282",
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
        "application_choice_id": 340774,
        "placements": [
            {
            "id": 270180,
            "trainee_id": 194065,
            "school_id": 26214,
            "urn": null,
            "name": null,
            "address": null,
            "postcode": null,
            "created_at": "2024-01-18T08:02:42.672Z",
            "updated_at": "2024-01-18T08:02:42.672Z",
            "slug": "SRsRAS4LfwZZXvSX7aAfNUm8"
            }
        ],
        "degrees": [
            {
            "id": 499040,
            "locale_code": "uk",
            "uk_degree": "Bachelor of Arts",
            "non_uk_degree": null,
            "trainee_id": 194065,
            "created_at": "2024-01-18T08:02:41.955Z",
            "updated_at": "2024-01-18T08:02:41.955Z",
            "subject": "Childhood studies",
            "institution": "University of Bristol",
            "graduation_year": 2022,
            "grade": "Upper second-class honours (2:1)",
            "country": null,
            "other_grade": null,
            "slug": "A9phsAcP3hDFMhx19qVGhtjL",
            "dttp_id": null,
            "institution_uuid": "0271f34a-2887-e711-80d8-005056ac45bb",
            "uk_degree_uuid": "db695652-c197-e711-80d8-005056ac45bb",
            "subject_uuid": "bf8170f0-5dce-e911-a985-000d3ab79618",
            "grade_uuid": "e2fe18d4-8655-47cf-ab1a-8c3e0b0f078f"
            }
        ]
    }

`HTTP 401` - Unauthorized

    {
        "error": "Unauthorized"
    }

---

### `GET /trainees/{trainee_id}/placements/{placement_id}`

This endpoint retrieves information about a single trainee.

#### Request

`GET /api/v0.1/trainees/{trainee_id}/placements/{placement_id}`

#### Possible responses

`HTTP 200` - A placement


`HTTP 401` - Unauthorized

    {
        "error": "Unauthorized"
    }


---

### `GET /trainees/{trainee_id}/placements`

This endpoint retrieves information about a single trainee.

#### Request

`GET /api/v0.1/trainees/{trainee_id}/placements`

#### Possible responses

`HTTP 200` - Array of placements


`HTTP 401` - Unauthorized

    {
        "error": "Unauthorized"
    }


---

### `GET /trainees/{trainee_id}/degrees/{degree_id}`

This endpoint retrieves information about a single trainee.

#### Request

`GET /api/v0.1/trainees/{trainee_id}/degrees/{degree_id}`

#### Possible responses

`HTTP 200` - A degree


`HTTP 401` - Unauthorized

    {
        "error": "Unauthorized"
    }


---

### `GET /trainees/{trainee_id}/degrees`

This endpoint retrieves information about a single trainee.

#### Request

`GET /api/v0.1/trainees/{trainee_id}/degrees`

#### Possible responses

`HTTP 200` - Array of degrees


`HTTP 401` - Unauthorized

    {
        "error": "Unauthorized"
    }
