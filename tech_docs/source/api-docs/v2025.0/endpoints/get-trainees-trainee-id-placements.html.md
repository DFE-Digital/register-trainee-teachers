---
title: GET /trainees/{trainee_id}/placements
weight: 4
---

# `GET /trainees/{trainee_id}/placements`

Get many placements for a trainee.

## Request

```
GET /api/v2025.0/trainees/{trainee_id}/placements
```

## Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |

## Possible responses

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
