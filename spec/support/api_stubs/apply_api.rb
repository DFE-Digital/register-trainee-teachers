# frozen_string_literal: true

module ApiStubs
  module ApplyApi
    def self.applications
      { data: [application] }.to_json
    end

    def self.application
      uk_application.to_json
    end

    def self.uk_application
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
          contact_details: contact_details,
          course: course,
          qualifications: qualifications,
          hesa_itt_data: {},
        },
      }
    end

    def self.non_uk_application
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
          qualifications: qualifications,
          hesa_itt_data: {},
        },
      }
    end

    def self.uk_degree
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
        hesa_degctry: nil,
        hesa_degstdt: "-01-01",
        hesa_degenddt: "2020-01-01",
      }
    end

    def self.non_uk_degree
      {
        id: 123,
        qualification_type: "BA",
        non_uk_qualification_type: "High School Diploma",
        subject: "History and Politics",
        grade: "AA*B",
        start_year: "1989",
        award_year: "1992",
        institution_details: "University of Huddersfield",
        equivalency_details: "Enic: 4000123456 - Between GCSE and GCSE AS Level - Equivalent to GCSE C",
        comparable_uk_degree: "masters_degree",
        hesa_degtype: "085",
        hesa_degsbj: "100323",
        hesa_degclss: "12",
        hesa_degest: "0052",
        hesa_degctry: "KN",
        hesa_degstdt: "2021-01-01",
        hesa_degenddt: "2020-01-01",
      }
    end

    def self.candidate_info
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
        disability_disclosure: nil,
        gender: "female",
        disabilities: %w[blind long_standing],
        ethnic_group: "",
        ethnic_background: "Chinese",
      }
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

    def self.qualifications
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
        degrees: [uk_degree],
        other_qualifications: [],
        missing_gcses_explanation: nil,
      }
    end

    def self.course
      {
        recruitment_cycle_year: 2021,
        course_code: "V6X1",
        training_provider_code: "E84",
        training_provider_type: "scitt",
        accredited_provider_type: nil,
        site_code: "-",
        study_mode: "full_time",
      }
    end
  end
end
