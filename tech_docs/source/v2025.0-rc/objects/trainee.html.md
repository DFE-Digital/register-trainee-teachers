---
title: Trainee object
weight: 1
---

# Trainee object

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
        string (limited to 50 characters)
      </p>
      <p class="govuk-body">
        The unique ID of the trainee in the Provider’s student record system (SRS). Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/ownstu">HESA provider’s own identifier for student field</a>.
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
        integer
      </p>
      <p class="govuk-body">
        The unique ID of the application choice in the Apply system.
      </p>
      <p class="govuk-body">
        Example: <code>123456</code>
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
        The date of birth of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/birthdte">HESA date of birth field</a>
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
        The sex of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/sexid">HESA sex identifier field</a>
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
        string (limited to 2 characters)
      </p>
      <p class="govuk-body">
        The nationality of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/nation">HESA nationality field</a>
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
        The email address of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/nqtemail">HESA email addresses field</a>
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
        The ethnicity of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/ethnic">HESA ethnicity field</a>. The values for <code>ethnic_background</code> and <code>ethnic_group</code> will be set based on the <code>ethnicity</code> value.
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
        The type of disabilities that the trainee has. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/disable">HESA disability field</a>
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
        The general qualification aim of the course in terms of qualifications and professional statuses. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/ittaim">HESA ITT qualification aim field</a>
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
        The training route that the trainee is on.
      </p>
      <p class="govuk-body">
        Possible values:
      </p>
      <ul>
        <li><code>02</code> - School Direct tuition fee</li>
        <li><code>03</code> - School Direct salaried</li>
        <li><code>09</code> - Undergraduate Opt-in</li>
        <li><code>10</code> - Postgraduate teaching apprenticeship</li>
        <li><code>11</code> - Primary and Secondary Undergraduate Fee Funded</li>
        <li><code>12</code> - Primary and Secondary Postgraduate Fee Funded</li>
        <li><code>14</code> - Teacher Degree Apprenticeship</li>
        </ul>
      <p class="govuk-body">
        Example: <code>11</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>itt_qualification_aim</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 3 characters), required if <code>itt_aim</code> is <code>202</code>
      </p>
      <p class="govuk-body">
        The qualification aim of the trainee’s course. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/qlaim">HESA qualification aim field</a>.
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
        The subjects included in the trainee’s course. The first subject is the main one. It represents the bursary or scholarship available if applicable. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/sbjca">HESA subject of ITT course field</a>.
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
        This indicates whether the trainee’s course is full-time or part-time. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/mode">HESA mode of study field</a>.
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
        The year number of the course that the trainee is currently studying. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/yearprg">HESA year of course field</a>
      </p>
      <p class="govuk-body">
        Example: <code>2</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>course_min_age</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        integer
      </p>
      <p class="govuk-body">
        The lower bound of the age range of children taught on the course (read-only).
      </p>
      <p class="govuk-body">
        Example: <code>7</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>course_max_age</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        integer
      </p>
      <p class="govuk-body">
        The upper bound of the age range of children taught on the course (read-only).
      </p>
      <p class="govuk-body">
        Example: <code>11</code>
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
        The age range of children taught on the course. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/ittphsc">HESA ITT phase/scope field</a>
      </p>
      <p class="govuk-body">
        Example: <code>13918</code>
      </p>
      <p class="govuk-body">
        The following HESA values are invalid for this field:
        <ul class='govuk-list govuk-list--bullet'>
          <li><code>99801</code> - Teacher training qualification: Further education/Higher education</li>
          <li><code>99803</code> - Teacher training qualification: Other</li>
        </ul>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>lead_partner_urn</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 6 characters)
      </p>
      <p class="govuk-body">
        The Unique Reference Number (URN) of the lead partner for the trainee.
      </p>
      <p class="govuk-body">
        Example: <code>123456</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>lead_partner_ukprn</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 8 characters)
      </p>
      <p class="govuk-body">
        The UK Provider Reference Number (UKPRN) of the lead partner for the trainee. If
        <code>lead_partner_urn</code> and <code>lead_partner_ukprn</code> are both provided,
        the <code>lead_partner_urn</code> will be used.
      </p>
      <p class="govuk-body">
        Example: <code>12345678</code>
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
        The start date of a trainee’s postgraduate teaching apprenticeship. Dates should be in ISO 8601 format.
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
    <dt class="govuk-summary-list__key"><code>fund_code</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 1 characters), required
      </p>
      <p class="govuk-body">
        The funding eligibility of the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/fundcode">HESA fundability code field</a>
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
        The bursary level awarded to the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/burslev">HESA bursary level award field</a>
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
        The main training initiative that the trainee is on. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/initiatives">HESA initiatives field</a>
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
        The secondary training initiative that the trainee is on. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/initiatives">HESA initiatives field</a>
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
        The HESA unique student identifier for the trainee. Coded according to the <a href="https://www.hesa.ac.uk/collection/c24053/e/husid">HESA unique student identifier field</a>
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
        The trainee’s National Insurance number.
      </p>
      <p class="govuk-body">
        Example: <code>BX5867459C</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>reinstate_date</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        date
      </p>
      <p class="govuk-body">
        The trainee’s reinstate date. (read-only)
      </p>
      <p class="govuk-body">
        Example: <code>2023-10-01</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>course_education_phase</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string
      </p>
      <p class="govuk-body">
        The trainee’s course education phase. (read-only)
      </p>
      <p class="govuk-body">
        Example: <code>primary</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>record_source</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string
      </p>
      <p class="govuk-body">
        The trainee’s record source. (read-only)
      </p>
      <p class="govuk-body">
        Possible values:
      </p>
      <ul>
        <li><code>manual</code></li>
        <li><code>api</code></li>
        <li><code>csv</code></li>
        <li><code>hesa</code></li>
        <li><code>apply</code></li>
        <li><code>dttp</code></li>
      </ul>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>state</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string
      </p>
      <p class="govuk-body">
        The trainee’s record state. (read-only)
      </p>
      <p class="govuk-body">
        Possible values:
      </p>
      <ul>
        <li><code>draft</code></li>
        <li><code>submitted_for_trn</code></li>
        <li><code>trn_received</code></li>
        <li><code>recommended_for_award</code></li>
        <li><code>withdrawn</code></li>
        <li><code>deferred</code></li>
        <li><code>awarded</code></li>
      </ul>
    </dd>
  </div>
</dl>