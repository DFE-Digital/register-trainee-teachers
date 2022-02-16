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
            last_name: "Geoorge",
            email: "student.name@email.com",
            date_of_birth: "1978-08-13",
            ethnic_background: "80",
            gender: "1",
            trn: nil,
            ukprn: "10007713",
            trainee_id: "99157234/2/01",
            course_subject_one: "100346",
            course_subject_two: nil,
            course_subject_three: nil,
            itt_start_date: nil,
            study_mode: "01",
            course_min_age: "71",
            commencement_date: nil,
            training_initiative: "C",
            hesa_id: "0310261553101",
            applying_for_bursary: "7",
            international_address: "XF",
            withdraw_reason: nil,
            withdraw_date: nil,
            disability: "00",
            bursary_tier: "6",
            employing_school_id: "115795",
            lead_school_id: "115795",
            training_route: "02",
            nationality: "NZ",
            degrees: [{
              country: nil,
              grade: "01",
              graduation_year: "2005-07-01",
              institution: "0001",
              subject: nil,
              uk_degree: "999",
            }],
          })
        end
      end
    end
  end
end
