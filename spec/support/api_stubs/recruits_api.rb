# frozen_string_literal: true

module ApiStubs
  module RecruitsApi
    def self.applications
      { data: [application] }.to_json
    end

    def self.applications_page1
      { data: [application(id: "3772"), application(id: "3773")] }.to_json
    end

    def self.applications_page2
      { data: [application(id: "3774")] }.to_json
    end

    def self.application(id: "3772", course_attributes: {}, candidate_attributes: {}, degree_attributes: {}, status: "recruited")
      uk_application(
        id:,
        course_attributes:,
        candidate_attributes:,
        degree_attributes:,
        status:,
      ).to_json
    end

    def self.uk_application(id: "3772", course_attributes: {}, candidate_attributes: {}, degree_attributes: {}, status: "recruited")
      {
        id: id,
        type: "application",
        attributes: {
          support_reference: "NV6357",
          status: status,
          updated_at: "2020-06-17T09:05:53+01:00",
          submitted_at: "2020-06-11T15:54:15+01:00",
          recruited_at: "2020-06-17T09:05:53.165+01:00",
          candidate: candidate_info(candidate_attributes),
          contact_details: contact_details,
          course: course(course_attributes),
          qualifications: qualifications(degree_attributes),
          hesa_itt_data: {},
        },
      }
    end

    def self.non_uk_application(degree_attributes: {})
      {
        id: "3772",
        type: "application",
        attributes: {
          support_reference: "NV6357",
          status: "recruited",
          updated_at: "2020-06-17T09:05:53+01:00",
          submitted_at: "2020-06-11T15:54:15+01:00",
          recruited_at: "2020-06-17T09:05:53.165+01:00",
          candidate: candidate_info,
          contact_details: non_uk_contact_details,
          course: course,
          qualifications: non_uk_qualifications(degree_attributes),
          hesa_itt_data: {},
        },
      }
    end

    def self.uk_degree(degree_attributes = {})
      {
        id: 6242,
        qualification_type: "BA",
        non_uk_qualification_type: nil,
        subject: "Religious Studies",
        grade: "First class honours",
        start_year: nil,
        award_year: "2020",
        institution_details: "University of Warwick",
        equivalency_details: nil,
        comparable_uk_degree: nil,
        hesa_degtype: nil,
        hesa_degsbj: nil,
        hesa_degclss: "01",
        hesa_degest: nil,
        hesa_degctry: "XK",
        hesa_degstdt: "-01-01",
        hesa_degenddt: "2020-01-01",
      }.merge(degree_attributes)
    end

    def self.non_uk_degree(degree_attributes = {})
      {
        id: 123,
        qualification_type: "BA",
        non_uk_qualification_type: "High School Diploma",
        subject: "History and Politics",
        grade: "AA*B",
        start_year: "1989",
        award_year: "1992",
        institution_details: "",
        equivalency_details: "Enic: 4000123456 - Between GCSE and GCSE AS Level - Equivalent to GCSE C",
        comparable_uk_degree: "masters_degree",
        hesa_degtype: "",
        hesa_degsbj: "",
        hesa_degclss: "",
        hesa_degest: "",
        hesa_degctry: "KN",
        hesa_degstdt: "2021-01-01",
        hesa_degenddt: "2020-01-01",
      }.merge(degree_attributes)
    end

    def self.candidate_info(candidate_attributes = {})
      {
        id: "C3134",
        first_name: "Martin",
        last_name: "Wells",
        date_of_birth: "1998-03-18",
        nationality: %w[GB SH],
        domicile: "XF",
        uk_residency_status: "UK Citizen",
        uk_residency_status_code: "A",
        fee_payer: "02",
        english_main_language: true,
        english_language_qualifications: "",
        other_languages: "I have a GCSE in French and have a Italian aunt - or should I say zia!",
        disability_disclosure: "I am dyslexic",
        gender: "female",
        disabilities: ["Blindness or a visual impairment not corrected by glasses", "Long-term illness"],
        disabilities_and_health_conditions: [
          {
            text: "",
            hesa_code: "58",
            name: "Blindness or a visual impairment not corrected by glasses",
            uuid: "a31b75e7-659d-4547-9654-5fc1015ad2a5",
          },
          {
            text: "",
            hesa_code: "54",
            name: "Long-term illness",
            uuid: "9955ea7d-e147-4b12-8913-d0c4ec925409",
          },
        ],
        ethnic_group: "Asian or Asian British",
        ethnic_background: "Chinese",
      }.merge(candidate_attributes)
    end

    def self.contact_details
      {
        phone_number: "07111999222",
        address_line1: "102 Keenan Drive",
        address_line2: "Bedworth",
        address_line3: "Coventry",
        address_line4: "Warwickshire",
        postcode: "CV12 0EJ",
        country: "GB",
        email: "martin.wells@mailinator.com",
      }
    end

    def self.non_uk_contact_details
      {
        phone_number: "",
        address_line1: "Rio de Janeiro",
        address_line2: "",
        address_line3: "",
        address_line4: "",
        postcode: "",
        country: "BR",
        email: "martin.wells@mailinator.com",
      }
    end

    def self.qualifications(degree_attributes = {})
      {
        gcses: [
          {
            id: 6244,
            qualification_type: "gcse",
            non_uk_qualification_type: nil,
            subject: "english",
            grade: "A",
            start_year: nil,
            award_year: "2013",
            institution_details: nil,
            equivalency_details: nil,
            comparable_uk_degree: nil,
            hesa_degtype: nil,
            hesa_degsbj: nil,
            hesa_degclss: nil,
            hesa_degest: nil,
            hesa_degctry: nil,
            hesa_degstdt: nil,
            hesa_degenddt: nil,
          },
        ],
        degrees: [uk_degree(degree_attributes)],
        other_qualifications: [],
        missing_gcses_explanation: nil,
      }
    end

    def self.non_uk_qualifications(degree_attributes = {})
      {
        degrees: [non_uk_degree(degree_attributes)],
        other_qualifications: [],
        missing_gcses_explanation: nil,
      }
    end

    def self.course(course_attributes = {})
      {
        recruitment_cycle_year: Settings.apply_applications.create.recruitment_cycle_year,
        course_code: "V6X1",
        course_uuid: "c6b9f8f0-f8f8-4f0f-b8e2-f8f8f8f8f8f8",
        training_provider_code: "E84",
        training_provider_type: "scitt",
        accredited_provider_type: nil,
        accredited_provider_code: nil,
        site_code: "-",
        study_mode: "full_time",
      }.merge(course_attributes)
    end
  end
end
