# frozen_string_literal: true

require "rails_helper"

module Hesa
  module Parsers
    describe IttRecord do
      describe ".to_attributes" do
        let(:student_node) { ApiStubs::HesaApi.new.student_node }

        subject(:trainee_attributes) do
          described_class.to_attributes(student_node:)
        end

        it "returns an hash with mapped trainee attributes" do
          expect(trainee_attributes).to match({
            first_names: "Dave",
            last_name: "George",
            email: "student.name@email.com",
            date_of_birth: "1978-08-13",
            ethnic_background: "899",
            sex: "11",
            ukprn: "10007713",
            provider_trainee_id: "99157234/2/01",
            course_subject_one: "100346",
            course_subject_two: nil,
            course_subject_three: nil,
            itt_end_date: "2023-10-01",
            mode: "01",
            course_age_range: "13909",
            training_initiative: "009",
            hesa_id: "0310261553101",
            disability1: "95",
            disability2: nil,
            disability3: nil,
            disability4: nil,
            disability5: nil,
            disability6: nil,
            disability7: nil,
            disability8: nil,
            disability9: nil,
            bursary_level: "6",
            employing_school_urn: "115795",
            training_partner_urn: "115795",
            training_route: "02",
            nationality: "NZ",
            hesa_updated_at: "17/10/2016 14:27:04",
            itt_aim: "202",
            itt_qualification_aim: "032",
            course_programme_title: "FE Course 1",
            pg_apprenticeship_start_date: nil,
            fund_code: "7",
            year_of_course: "0",
            itt_key: "0101904000002",
            rec_id: "16053",
            status: "UPDATED",
            allocated_place: "2",
            provider_course_id: "E700",
            initiatives_two: nil,
            ni_number: nil,
            numhus: "02",
            previous_surname: "Geoorge",
            surname16: nil,
            ttcid: "1",
            hesa_committed_at: "2022-10-17 02:34:39",
            itt_start_date: "2023-01-01",
            trainee_start_date: "2023-01-02",
            application_choice_id: "56789",
            degrees: [{
              country: "XF",
              grade: "01",
              graduation_date: "2005-07-01",
              institution: "0001",
              subject_one: "100251",
              subject_two: "100038",
              subject_three: nil,
              degree_type: "205",
            }],
            placements: [{
              school_urn: "900000",
            }],
          })
        end
      end
    end
  end
end
