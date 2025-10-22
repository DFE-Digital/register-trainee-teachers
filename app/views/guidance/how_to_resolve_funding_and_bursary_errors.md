---
page_title: How to resolve funding and bursary errors when using the CSV or API
title: How to resolve funding and bursary errors when using the CSV or API
---

Some users are experiencing issues where they receive unexpected error messages
related to bursaries, scholarships or funding. The following problem statements
outline some of the causes of these errors.

If you continue to experience error messages, email
<a class='govuk-link' href="mailto:becomingateacher@digital.education.gov.uk">becomingateacher@digital.education.gov.uk</a>
<br/>
<br/>

## Problem Statement 1:
I was expecting a scholarship to be valid, but I’ve received an error message.

### Field causing the error:
Course Subject: Modern languages

### Reason for this error message:
Only French, Spanish and German are eligible for scholarships.

### Solution:
Under the field ‘Course Subject One’ (API: course_subject_one) ensure you’ve
specified French OR Spanish OR German as the course.

To be eligible for funding we need to know which specific language they are
studying so we can check they are eligible.

You can add Modern languages as a second course option.
<br/>
<br/>

## Problem Statement 2:
I was expecting a bursary to be valid, but I’ve received an error message.

### Field causing the error:
Course Subject: Modern languages<br/>
Fund Code: 2

### Reason for this error message:
A language must be specified. Choose from French OR Spanish OR German if the
trainee is not eligible for student finance (Fund Code 2).

### Solution:
Under the field ‘Course Subject One’ (API: course_subject_one)
ensure you’ve specified French OR Spanish OR German as the course.

You can add Modern languages as a second course option.
<br/>
<br/>

## Problem Statement 3:
I was expecting a bursary or scholarship to be valid, but I’ve received an error message.

### Fields causing the error:
Fund Code: 7<br/>
Course age range: ‘Empty field’

### Reason for this error message:
Funding is only given when it appears alongside the correct age range.

### Solution:
Under ‘Course Age Range’ select the correct ages for the course the trainee is doing.
<br/>
<br/>

## Problem Statement 4:
I was expecting funding to be valid.

### Field causing the error:
Fund Code: ‘Empty field’

### Reason for this error message:
The Fund Code field can’t be left empty.

### Solution:
A Fund Code is required.
<br/>
<br/>
