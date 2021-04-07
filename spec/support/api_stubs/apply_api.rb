# frozen_string_literal: true

module ApiStubs
  module ApplyApi
    def self.applications
      { "data": [application] }.to_json
    end

    def self.application
      {
        "id": "3772",
        "type": "application",
        "attributes": {
          "support_reference": "NV6357",
          "status": "recruited",
          "updated_at": "2020-06-17T09:05:53+01:00",
          "submitted_at": "2020-06-11T15:54:15+01:00",
          "recruited_at": "2020-06-17T09:05:53.165+01:00",
          "candidate": {
            "id": "C3134",
            "first_name": "Martin",
            "last_name": "Wells",
            "date_of_birth": "1998-03-18",
            "nationality": %w[GB],
            "domicile": "XF",
            "uk_residency_status": "UK Citizen",
            "uk_residency_status_code": "A",
            "fee_payer": "02",
            "english_main_language": true,
            "english_language_qualifications": "",
            "other_languages": "I have a GCSE in French and have a Italian aunt - or should I say zia!",
            "disability_disclosure": nil,
            "gender": "",
            "disabilities": [],
            "ethnic_group": "",
            "ethnic_background": "",
          },
          "contact_details": {
            "phone_number": "07111999222",
            "address_line1": "102 Keenan Drive",
            "address_line2": "Bedworth",
            "address_line3": "Coventry",
            "address_line4": "Warwickshire",
            "postcode": "CV12 0EJ",
            "country": "GB",
            "email": "martin.wells@mailinator.com",
          },
          "course": {
            "recruitment_cycle_year": 2021,
            "course_code": "V6X1",
            "training_provider_code": "E84",
            "site_code": "-",
            "study_mode": "full_time",
          },
          "qualifications": {
            "gcses": [
              {
                "id": 6244,
                "qualification_type": "gcse",
                "non_uk_qualification_type": nil,
                "subject": "english",
                "grade": "A",
                "start_year": nil,
                "award_year": "2013",
                "institution_details": nil,
                "equivalency_details": nil,
                "comparable_uk_degree": nil,
                "hesa_degtype": nil,
                "hesa_degsbj": nil,
                "hesa_degclss": nil,
                "hesa_degest": nil,
                "hesa_degctry": nil,
                "hesa_degstdt": nil,
                "hesa_degenddt": nil,
              },
            ],
            "degrees": [
              {
                "id": 6242,
                "qualification_type": "BA",
                "non_uk_qualification_type": nil,
                "subject": "Religious Studies",
                "grade": "First class honours",
                "start_year": nil,
                "award_year": "2020",
                "institution_details": "University of Warwick",
                "equivalency_details": nil,
                "comparable_uk_degree": nil,
                "hesa_degtype": nil,
                "hesa_degsbj": nil,
                "hesa_degclss": "01",
                "hesa_degest": nil,
                "hesa_degctry": nil,
                "hesa_degstdt": "-01-01",
                "hesa_degenddt": "2020-01-01",
              },
            ],
            "other_qualifications": [],
            "missing_gcses_explanation": nil,
          },
          "hesa_itt_data": {},
        },
      }.to_json
    end
  end
end
