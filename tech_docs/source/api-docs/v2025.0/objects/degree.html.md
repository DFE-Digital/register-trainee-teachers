---
title: Degree object
weight: 3
---

# Degree object

<dl class="govuk-summary-list">
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>degree_id</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 24 characters)
      </p>
      <p class="govuk-body">
        The unique ID of the degree in the Register system. Used to identify the degree when <a href="/api-docs/v2025.0/endpoints/put-patch-trainees-trainee-id-degrees-degree-id.html">updating</a> or <a href="/api-docs/v2025.0/endpoints/delete-trainees-trainee-id-degrees-degree-id.html">deleting</a>.
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
        The country where the degree was awarded.
        Coded according to the
        <a href="/reference-data/v2025.0/country.html">degree country reference data specification</a>.
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
        The grade of the degree. Coded according to
        <a href="/reference-data/v2025.0/grade.html">degree grade reference data specification</a>.
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
        The type of UK degree. Coded according to
        <a href="/reference-data/v2025.0/uk-degree.html">degree type reference data specification</a>.
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
        The type of non-UK degree. Coded according to
        <a href="/reference-data/v2025.0/non-uk-degree.html">non-UK degree type reference data specification</a>.
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
        The degree subject. For those with complex previous degrees, return the major subject that you would have previously returned as degree subject 1. Coded according to
        <a href="/reference-data/v2025.0/subject.html">degree subject reference data specification</a>.
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
        The awarding institution. Coded according to the
        <a href="/reference-data/v2025.0/institution.html">awarding institution reference data specification</a>.
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
         This can be formatted as an ISO-8601 format date <code>YYYY-MM-DD</code> or just the year <code>YYYY</code>
      </p>
      <p class="govuk-body">
         Where only the month and year are known, just use the year.
      </p>
      <p class="govuk-body">
        Example: <code>2012-07-31</code> or <code>2012</code>
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
