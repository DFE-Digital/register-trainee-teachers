---
title: GET /trainees/{trainee_id}/placements/{placement_id}
weight: 5
---

# `GET /trainees/{trainee_id}/placements/{placement_id}`

Get a single placement for a trainee.

## Request

`GET /api/v2025.0-rc/trainees/{trainee_id}/placements/{placement_id}`

## Parameters

| **Parameter** | **In**  | **Type** | **Required** | **Description** |
| ------------- | ------- | -------- | ------------ | --------------- |
| **trainee_id** | path | string | true | The unique ID of the trainee |
| **placement_id** | path | string | true | The unique ID of the placement |

## Possible responses

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