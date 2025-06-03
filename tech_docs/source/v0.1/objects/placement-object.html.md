---
title: Placement object
weight: 2
---


# Placement object


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