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
        The unique ID of the trainee in the Register system. Used to identify the trainee when using endpoints which require a <code>trainee_id</code>.
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
        The unique ID of the trainee in the Provider’s student record system (SRS).
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
        This field records the date of birth of the student.
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
        The sex of the trainee. Coded according to the <a
          href="/reference-data/v2025.0/sex.html">Sex reference data specification</a>.
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
        The nationality of the trainee. Coded according to the <a
          href="/reference-data/v2025.0/nationality.html">Nationality reference data specification</a>.
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
        This must be a trainee’s personal email address. DfE uses this to communicate to trainees after they have left their training course, for example, regarding their QTS.
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
        The ethnicity of the trainee. Coded according to the <a
          href="/reference-data/v2025.0/ethnicity.html">Ethnicity reference data specification</a>. The values for
        <code>ethnic_background</code> and <code>ethnic_group</code> will be set based on the <code>ethnicity</code>
        value.
      </p>
      <p class="govuk-body">
       Note: If no ethnicity value is provided (blank or null), the system will automatically
        set this field to <code>997</code> (Not provided).
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
        The type of disabilities that the trainee has. Coded according to the <a
          href="/reference-data/v2025.0/disability1.html">Disability reference data specification</a>
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
        The general qualification aim of the course in terms of qualifications and professional statuses. Coded according to the <a
          href="/reference-data/v2025.0/itt-aim.html">ITT Aim reference data specification</a>
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
        The training route that the trainee is on. Coded according to the <a
          href="/reference-data/v2025.0/training-route.html">Training Route reference data specification</a>
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
        string (limited to 3 characters), required if <code>itt_aim</code> is <code>202</code>
      </p>
      <p class="govuk-body">
        The qualification aim of the trainee’s course. Coded according to the <a
          href="/reference-data/v2025.0/itt-qualification-aim.html">Qualification Aim reference data specification</a>
      </p>
      <p class="govuk-body">
        Example: <code>004</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>course_subject_one</code>, <code>course_subject_two</code>,
      <code>course_subject_three</code>
    </dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 6 characters), <code>course_subject_one</code> is required
      </p>
      <p class="govuk-body">
        The subjects included in the trainee’s course. The first subject is the main one. It represents the bursary or
        scholarship available if applicable. Coded according to the <a
          href="/reference-data/v2025.0/course-subject-one.html">Course Subject reference data specification</a>.
      </p>
      <p class="govuk-body">
        Notes:
        Where the course maximum age is 11 or less as stated in <code>course_age_range</code>,
        we expect <code>course_subject_one</code> to be “Primary Teaching”. We will automatically apply HESA code <code>100511</code> if you have not already done so.
        Any subjects provided in the trainee details will be shifted to <code>course_subject_two</code> and <code>course_subject_three</code>.
        Where trainees study a primary specialism, a valid HECoS code should be used in this field.
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
        This indicates whether the trainee’s course is full-time or part-time. Coded according to the <a
          href="/reference-data/v2025.0/study-mode.html">Study Mode reference data specification</a>
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
        string, required (must not be more than one year in the future)
      </p>
      <p class="govuk-body">
        The start date of the Initial Teacher Training part of their course.
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
        The end date of the Initial Teacher Training part of their course.
        Includes planned assessment periods, or planned writing-up periods.
        Update this field if there’s a change, for example, resits, agreed
        breaks or transferring between courses.
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
        The year number of the course that the trainee is currently studying.
        Possible values:
      </p>
      <ul>
        <li><code>0</code> - Foundation year</li>
        <li><code>1</code> - First year</li>
        <li><code>2</code> - Second year</li>
        <li><code>3</code> - Third year</li>
      </ul>
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
        The age range of children taught on the course. Coded according to the <a
          href="/reference-data/v2025.0/course-age-range.html">Course Age Range reference data specification</a>
      </p>
      <p class="govuk-body">
        Example: <code>13918</code>
      </p>
      <p class="govuk-body">
        The following values are invalid for this field:
      </p>
      <ul>
        <li><code>99801</code> - Teacher training qualification: Further education/Higher education</li>
        <li><code>99803</code> - Teacher training qualification: Other</li>
      </ul>
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
        Examples:
      </p>
      <ul>
        <li><code>115795</code> - Cheltenham College</li>
        <li><code>133795</code> - University of Sussex</li>
      </ul>
      <p class="govuk-body">
        Other possible values:
      </p>
      <ul>
        <li><code>900000</code> - Establishment outside England and Wales</li>
        <li><code>900020</code> - Other establishment without a URN</li>
        <li><code>900030</code> - Not available</li>
      </ul>
      <p class="govuk-body">
       Note: The system validates the provided URN against the Register database.
        If the URN is not found in Register, the request will not return an error but the
        lead partner association may not be established correctly.
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
        string (must be in the past and not more than 10 years ago)
      </p>
      <p class="govuk-body">
        The start date of the trainee on their ITT course.
      </p>
      <p class="govuk-body">
       Note: If <code>trainee_start_date</code> is not provided, it will be automatically
        set to the value of <code>itt_start_date</code>. The <code>trainee_start_date</code> is validated to ensure it is not
        more than 10 years in the past, and cannot be in the future unless it matches <code>itt_start_date</code>.
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
        The start date of a trainee’s postgraduate teaching apprenticeship.
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
        Example:
      </p>
      <ul>
        <li><code>123456</code></li>
        <li><code>900000</code> - Establishment outside England and Wales</li>
        <li><code>900020</code> - Other establishment without a URN</li>
        <li><code>900030</code> - Not available</li>
      </ul>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>fund_code</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string (limited to 1 characters), required
      </p>
      <p class="govuk-body">
        Possible values:
      </p>
      <ul>
        <li><code>2</code> - not eligible for student finance</li>
        <li><code>7</code> - eligible for student finance</li>
      </ul>
      <p class="govuk-body">
        Note: Use <code>7</code> if the trainee chooses not to receive the finance they are eligible for.
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
        The bursary level awarded to the trainee. Coded according to the <a
          href="/reference-data/v2025.0/funding-method.html">Funding Method reference data specification</a>
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
        This field identifies students who are part of a specific scheme that
        is to be monitored independently. Valid entries will change from year to year
        to reflect current schemes. Coded according to the <a
          href="/reference-data/v2025.0/training-initiative.html">Training Initiative reference data specification</a>
      </p>
      <p class="govuk-body">
        Example: <code>026</code>
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
        The secondary training initiative that the trainee is on. Coded according to the <a
          href="/reference-data/v2025.0/training-initiative.html">Training Initiative reference data specification</a>.
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
        string (must be 13 or 17 characters), required
      </p>
      <p class="govuk-body">
        The HESA unique student identifier for the trainee.
      </p>
      <p class="govuk-body">
        Example: <code>12100071451234560</code>
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
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>withdraw_date</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string
      </p>
      <p class="govuk-body">
        This field records the date on with the trainee withdrew.
      </p>
      <p class="govuk-body">
        Example: <code>2025-01-01</code>
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>withdraw_reasons</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        array of strings
      </p>
      <p class="govuk-body">
        The list of reasons for the trainee’s withdrawal. (read-only)
      </p>
      <p class="govuk-body">
        Possible values:
      </p>
      <ul>
        <li><code>death</code></li>
        <li><code>did_not_pass_assessment</code></li>
        <li><code>did_not_pass_exams</code></li>
        <li><code>exclusion</code></li>
        <li><code>personal_reasons</code></li>
        <li><code>transferred_to_another_provider</code></li>
        <li><code>written_off_after_lapse_of_time</code></li>
        <li><code>course_was_not_suitable</code></li>
        <li><code>family_problems</code></li>
        <li><code>financial_problems</code></li>
        <li><code>got_a_job</code></li>
        <li><code>problems_with_their_health</code></li>
        <li><code>unhappy_with_course_provider_or_employing_school</code></li>
        <li><code>unacceptable_behaviour</code></li>
        <li><code>lack_of_progress_during_placements</code></li>
        <li><code>did_not_make_progress</code></li>
        <li><code>could_not_give_enough_time</code></li>
        <li><code>did_not_meet_entry_requirements</code></li>
        <li><code>teaching_placement_problems</code></li>
        <li><code>does_not_want_to_become_a_teacher</code></li>
        <li><code>stopped_responding_to_messages</code></li>
        <li><code>record_added_in_error</code></li>
        <li><code>mandatory_reasons</code></li>
        <li><code>not_meeting_qts_standards</code></li>
        <li><code>change_in_personal_or_health_circumstances</code></li>
        <li><code>never_intended_to_obtain_qts</code></li>
        <li><code>moved_to_different_itt_course</code></li>
        <li><code>had_to_withdraw_trainee_another_reason</code></li>
        <li><code>trainee_chose_to_withdraw_another_reason</code></li>
        <li><code>trainee_workload_issues</code></li>
        <li><code>another_reason</code></li>
        <li><code>unknown</code></li>
        <li><code>safeguarding_concerns</code></li>
      </ul>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>withdrawal_future_interest</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string
      </p>
      <p class="govuk-body">
        Whether the trainee has expressed future interest in teacher training. (read-only)
      </p>
      <p class="govuk-body">
        Possible values:
      </p>
      <ul>
        <li><code>yes</code></li>
        <li><code>no</code></li>
      </ul>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>withdrawal_trigger</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string
      </p>
      <p class="govuk-body">
        Whether the trainee’s withdrawal was triggered by the provider or the trainee. (read-only)
      </p>
      <p class="govuk-body">
        Possible values:
      </p>
      <ul>
        <li><code>provider</code></li>
        <li><code>trainee</code></li>
      </ul>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>withdrawal_another_reason</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string
      </p>
      <p class="govuk-body">
        When the reason for withdrawal is 'another_reason', this field provides additional context. (read-only)
      </p>
    </dd>
  </div>
  <div class="govuk-summary-list__row govuk-summary-list__row--no-actions">
    <dt class="govuk-summary-list__key"><code>withdrawal_safeguarding_concern_reasons</code></dt>
    <dd class="govuk-summary-list__value">
      <p class="govuk-body">
        string
      </p>
      <p class="govuk-body">
        When the reason for withdrawal is 'safeguarding_concerns', this field provides additional context. (read-only)
      </p>
    </dd>
  </div>
</dl>
