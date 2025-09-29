---
title: GET /trainees/{trainee_id}/degrees/{degree_id}
weight: 7
---

# `GET /trainees/{trainee_id}/degrees/{degree_id}`

Get a single degree for a trainee.

## Request

```
GET /api/v2025.0/trainees/{trainee_id}/degrees/{degree_id}
```

## Parameters

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
