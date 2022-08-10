# frozen_string_literal: true

require "rails_helper"

module Hesa
  module Parsers
    describe IttRecord do
      describe ".to_attributes" do
        let(:student_node) { ApiStubs::HesaApi.new.student_node }

        subject(:trainee_attributes) do
          described_class.to_attributes(student_node: student_node)
        end

        it "returns an hash with mapped trainee attributes" do
          expect(trainee_attributes).to match({
            first_names: "Dave",
            last_name: "George",
            email: "student.name@email.com",
            date_of_birth: "1978-08-13",
            ethnic_background: "899",
            sex: "11",
            trn: nil,
            ukprn: "10007713",
            trainee_id: "99157234/2/01",
            course_subject_one: "100346",
            course_subject_two: nil,
            course_subject_three: nil,
            itt_start_date: "2016-09-27",
            itt_end_date: "2017-10-01",
            mode: "01",
            course_age_range: "13909",
            commencement_date: nil,
            training_initiative: "009",
            hesa_id: "0310261553101",
            reason_for_leaving: nil,
            end_date: nil,
            disability: "00",
            bursary_level: "6",
            employing_school_urn: "115795",
            lead_school_urn: "115795",
            training_route: "02",
            nationality: "NZ",
            hesa_updated_at: "17/10/2016 14:27:04",
            itt_aim: "202",
            itt_qualification_aim: "032",
            course_programme_title: "FE Course 1",
            pg_apprenticeship_start_date: nil,
            fund_code: "7",
            study_length: "3",
            study_length_unit: "1",
            year_of_course: "0",
            degrees: [{
              country: "XF",
              grade: "01",
              graduation_date: "2005-07-01",
              institution: "0001",
              subject: "100251",
              degree_type: "205",
            }],
            placements: [{ school_urn: "900000" }],
          })
        end
      end
    end
  end
end
