---
page_title: How to resolve funding and bursary errors when using the CSV or API
title: How to resolve funding and bursary errors when using the CSV or API
---

Some users are experiencing issues where they receive unexpected error messages related to bursaries or funding. The following problem statements outline the main causes of these errors.

If you continue to experience error messages, email
<a class='govuk-link' href="mailto:becomingateacher@digital.education.gov.uk">becomingateacher@digital.education.gov.uk</a>

## Problem Statement 1:
I was expecting a bursary to be valid but I’ve received an error message.

### Field causing the error:
Course Subject: Modern languages

### Reason for this error message:
Only French, Spanish and German are eligible for funding.

### Solution:
Under the field ‘Course Subject One’ (API: course_subject_one) ensure you’ve
specified French OR Spanish OR German as the course.

You can add Modern languages as a second course option.


## Problem Statement 2:

I was expecting a bursary to be valid but I’ve received an error message.

### Field causing the error:
Course subject: Mathematics and Physics

### Reason for this error message:
Mathematics is not eligible for funding. In this scenario Mathematics is the
first course mentioned which is causing an error message.

### Solution:
Under ‘Course Subject One’ ensure you’ve put Physics.
You can add Mathematics as a second course option.

## Problem Statement 3:

I was expecting a bursary to be valid but I’ve received an error message.

### Fields causing the error:
Fund Code: 7<br/>
Course age range: ‘Empty field’

### Reason for this error message:
Funding is only given when it appears alongside the correct age range.

### Solution:
Under ‘Course Age Range’ select the correct ages for the course the trainee is doing.

## Problem Statement 4:

I was expecting funding to be valid.

### Field causing the error:
Fund Code: ‘Empty field’

### Reason for this error message:
A value of ‘7’ is required for someone to be entitled to funding.

### Solution:
Use value ‘7’ in the Fund Code field.

## Problem Statement 5:

My trainee isn’t eligible for funding but is doing a course that is eligible for bursary.

### Fields causing the error:

Fund Code: 2<br/>
Course Subject: Ancient languages/Modern languages/French/German/Spanish <b>OR</b> Physics<br/>
ITT Start Date: ‘Empty field’ or ‘Incorrect year’

### Reason for this error message:
The bursary eligibility is only for academic year 2025-26.

### Solution:
Use an ITT Start Date of 2025 on a postgrad or applicable route.
