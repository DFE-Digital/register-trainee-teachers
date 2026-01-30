# frozen_string_literal: true

module ApiStubs
  module TeacherTrainingApi
    def self.subjects
      { data: [subject] }
    end

    def self.subject(attrs = {})
      {
        id: "3",
        type: "subjects",
        attributes: {
          name: "Primary with science",
          code: "07",
          bursary_amount: "9000",
          early_career_payments: "8388",
          scholarship: "3500",
          subject_knowledge_enhancement_course_available: true,
        }.merge(attrs),
      }
    end

    def self.courses
      { data: [course], links: { next: nil } }
    end

    def self.course(attrs = {})
      {
        id: "12940536",
        type: "courses",
        attributes: {
          accredited_body_code: "8BX",
          age_maximum: 18,
          age_minimum: 11,
          bursary_amount: nil,
          bursary_requirements: [],
          created_at: "2020-07-05T13:17:55Z",
          funding_type: "fee",
          gcse_subjects_required: %w[maths english],
          level: "secondary",
          name: "Physical Education",
          program_type: "scitt_programme",
          training_route: "fee_funded_initial_teacher_training",
          degree_type: "postgraduate",
          qualifications: %w[qts pgce],
          scholarship_amount: nil,
          study_mode: "full_time",
          uuid: "fb1ee2ff-f3c5-4388-8c1b-690ce090c45e",
          about_accredited_body: nil,
          applications_open_from: "2020-10-13",
          changed_at: "2021-03-08T11:42:35Z",
          code: "2B7B",
          findable: true,
          has_early_career_payments: false,
          has_scholarship: false,
          has_vacancies: false,
          is_send: false,
          last_published_at: "2020-10-06T16:27:07Z",
          open_for_applications: true,
          required_qualifications_english: "equivalence_test",
          required_qualifications_maths: "equivalence_test",
          required_qualifications_science: "not_set",
          running: true,
          start_date: "September 2021",
          state: "published",
          summary: "PGCE with QTS full time",
          subject_codes: %w[C6],
          about_course: "Here is a brief overview of our programme - for more details please visit [YTCA SCITT: Programme Information.](http://ytcascitt.co.uk/scitt-programme/)\r\n\r\nOur well-established programme, rated 'Good' by Ofsted (2016), requires trainees to develop a wide range of teaching skills, to reflect on their practice, and to demonstrate they meet the Teachers’ Standards.  \r\n\r\nIn summary we offer:\r\n* a mixture of experiential and academic learning;\r\n* high-quality training delivered by skilled and experienced practitioners;\r\n* placements in at least two schools with the opportunity to experience other specialised educational settings;\r\n* bespoke curriculum and subject knowledge development training;\r\n* excellent pastoral care, well-being training and support;\r\n* one-to-one personalised support throughout the training year from in-school mentors and the YTCA SCITT team;\r\n* inclusion of a PGCE in Education led by Sheffield Hallam University (four taught sessions, two modules, two practice-based assignments);\r\n* the opportunity to complete a two-day Youth Mental Health First Aid training course;\r\n* support with finding school employment once qualified.\r\n\r\nOur core curriculum is primarily delivered through \"Hub Days\". Our course structure follows a coherent 3-week cycle starting with an Academic Tutorial for each aspect of pedagogy that you will look at.  After some time in school, this is followed by a practical workshop led by practicing teachers who are expert practitioners.  The workshops are designed to develop strategies and skills for the classroom as well as opportunities to network with other trainees and reflect on practice.   Finally you are supported to implement what you have learnt in your own teaching by your school mentors.\r\n\r\nHub days also include show and tell sessions where you can share something that has worked well, a challenge or good resource, and reflection sessions to revisit your practice at regular intervals.  \r\n\r\nWe also have our own SCITT book club with the challenge to read as many of the books as possible by the end of the year!\r\n\r\nAssessment for this course is through school experience (placements), a Reflective Portfolio which is primarily based online and consists of elements such as development records, Academic Tutorial work, school-based tasks and presentations where you focus on a particular theme/topic/class and share your reflections about your development and impact on learning.\r\n\r\nThe next full and part-time programmes will start in September 2021 and, for those trainees that meet the Teachers’ Standards, finish in June/July 2022 (full-time - dates TBC) or sometime in 2023 (part-time, dependent on timetable) ",
          course_length: "1 year (full-time) or up to 2 years (part-time)",
          fee_details: "The cost for the course is £9250.  Candidates may be eligible for a student loan, bursary or scholarship. \r\n\r\nPlease visit [Get into Teaching: An overview of funding](https://getintoteaching.education.gov.uk/funding-and-salary/overview) for more information.",
          fee_international: nil,
          fee_domestic: 9250,
          financial_support: "",
          how_school_placements_work: "The placements you complete during your training year will give you a breadth of experience and provide a range of opportunities for you to demonstrate you have met all the Teachers’ Standards.\r\n\r\nWe currently have 6 excellent secondary partner schools with a proven track record of developing outstanding trainees.  \r\n\r\nThe SCITT operates “AB” and “ABA” placement models depending on your course: \r\n\r\n* Trainees undertaking Secondary 11-16 and Secondary 11-19 (with school-based Post-16 training) courses will follow the “AB” model.\r\n\r\nPlacement A consists of 2 school induction days and 16 assessed teaching weeks. This is your opportunity to develop your core teaching skills.\r\n\r\nPlacement B consists of 2 school induction days and 14 teaching weeks. You will be placed in a contrasting school so you can experience different things and develop your skills in different areas.\r\n\r\n* Trainees undertaking a Secondary 11-19 course (with college-based Post-16 training) will follow the “ABA” model.\r\nPlacement A (part 1) consists of 2 school induction days and 10 assessed teaching weeks. This is your opportunity to develop your core teaching skills.\r\n\r\nPlacement B is with one of our Post-16 partners. This placement consists of 2 induction days and 10 teaching weeks. It is an opportunity to focus on teaching Post-16 in a contrasting setting so you can experience different things and develop your skills in different areas.\r\n\r\nYou will then return to Placement A (part 2) to further refine your skills in a school setting (a further 10 assessed teaching weeks).\r\n\r\nWe also have time dedicated to Enrichment Experiences which include:\r\n* Two days in a KS2 and two days in a KS5 setting;\r\n* Completion of a two-day Youth Mental Health First Aid Training course;\r\n* Some trainees may also spend a day in other educational settings. These might include visits to a Pupil Referral Unit, Special Needs schools/units, schools with specialisms, etc.\r\n\r\nWe take into consideration information given to us by successful candidates regarding issues with travel, etc.\r\n\r\nPart-time calendars are created in negotiation with the trainee and their placement school – please [contact us](http://ytcascitt.co.uk/contact-us/) if you would like to discuss this further. ",
          interview_process: "Our aim is to be able to identify the highest quality candidates that meet our success criteria; those best prepared to begin QTS assessment and most likely to excellent teachers by the end of their training.  \r\n\r\nPlease note that the following information is subject to change due to the current COVID-19 pandemic.\r\n\r\nIf your application is successful, we will invite you to an interview at one of our partner schools.   The panel usually includes the SCITT Programmes Lead, a subject specialist and another ITT specialist. \r\n\r\nThe interview process includes:\r\n\r\n* Teaching a 25-minute lesson based on a topic and class data which you will receive prior to interview.  We do take into account that you may never have taught before so we aren’t looking for a perfect lesson!  Instead, we will be considering your potential to become a teacher!\r\n\r\n* A 10-minute presentation about the British education system, that you have pre-prepared;\r\n\r\n* A 30-minute interview which will cover your reasons for wanting to teach, your understanding of the role of the teacher, your own skills and attributes and how these might support you in your training and current issues in education.\r\n\r\n* Document check (ID \u0026 qualifications);\r\n\r\n* Subject knowledge test (30-40 minutes) - designed to assess the breadth and depth of your knowledge across the curriculum (primary) or in your subject (secondary).",
          other_requirements: "* Good subject knowledge (assessed at interview);\r\n\r\n* Whilst not compulsory, we recommend that you have some recent experience of working in a school so that you fully understand the expectations and demands of the role of a teacher.  It would be beneficial for you to observe some teaching in your chosen subject.  Please [visit this page](https://schoolexperience.education.gov.uk/) and enter: “WF9 2UJ” to arrange School Experience with us.\r\n\r\nIf successful at interview...\r\n\r\n* Completed medical questionnaire;\r\n* Enhanced DBS clearance by us which is subscribed to the Update Service;\r\n* RO2 and declaration form (relating to Rehabilitation of Offenders Act 1974).\r\n\r\n",
          personal_qualities: "We usually see candidates demonstrate the following in successful applications and interviews:\r\n* A genuine desire to support young people and help them develop and succeed;\r\n* Evidence of a commitment to and an understanding of a career in teaching;\r\n* A proactive and reflective approach to their own development;\r\n* The ability to relate to and engage with young people;\r\n* A passion for their subject;\r\n* Excellent interpersonal skills;\r\n* The ability to research and engage with current educational themes;\r\n* Effective communication skills including the ability to explain concepts clearly;\r\n* Initiative, innovation and resilience.",
          required_qualifications: "GCSEs at grade C/4 or above (or equivalent) in English Language and Mathematics.\r\n\r\nAn degree at classification 2:2 or above from a UK university (or equivalent):\r\n\r\n* All subjects are acceptable;\r\n* Third class degrees will be considered on an individual basis; \r\n* If you are in your final year at University we will look at your predicted grade.\r\n\r\nA-Levels (or equivalent) - if your degree is not directly related to the subject you want to teach we consider your A-level (or equivalent) qualifications.",
          salary_details: nil,
        }.merge(attrs),
        relationships: {
          accredited_body: {
            meta: {
              included: false,
            },
          },
          provider: {
            data: {
              type: "providers",
              id: "15987",
            },
          },
          recruitment_cycle: {
            meta: {
              included: false,
            },
          },
        },
      }
    end

    def self.lead_schools
      { data: [lead_school], links: { next: nil } }
    end

    def self.lead_school(attrs = {})
      {
        id: "18658",
        type: "providers",
        attributes: {
          ukprn: "10000000",
          urn: "100000",
          postcode: "N1 4PF",
          provider_type: "lead_school",
          region_code: "london",
          train_with_disability: "train with disability",
          train_with_us: "train with us",
          website: "https://www.test.org/",
          latitude: nil,
          longitude: nil,
          telephone: nil,
          email: "admin@test.org",
          can_sponsor_skilled_worker_visa: false,
          can_sponsor_student_visa: false,
          accredited_body: false,
          changed_at: "2023-08-13T07:37:23Z",
          city: "London",
          code: "R3G",
          county: "",
          created_at: "2022-08-06T11:52:52Z",
          name: "Register Primary School",
          street_address_1: "105 Register Street",
          street_address_2: "Jubilee Register Centre",
          street_address_3: nil,
          # rubocop:enable Naming/VariableNumber
        }.merge(attrs),
        relationships: {
          recruitment_cycle: {
            meta: {
              included: false,
            },
          },
        },
      }
    end
  end
end
