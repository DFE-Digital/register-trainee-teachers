---
title: GET /info
weight: 1
---

# `GET /info`

Provides general information about the API.


## Request

`GET /api/v0.1/info`


## Possible responses

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
