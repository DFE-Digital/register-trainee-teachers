# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20250Rc::CreateHesaTraineeDetailService do
  subject { described_class }

  describe "#call" do
    describe "success" do
      context "for a trainee without a hesa_trainee_detail record" do
        let(:trainee) { create(:trainee) }

        it "creates a hesa_trainee_detail record" do
          trainee.reload
          expect { subject.call(trainee:) } .to change { Hesa::TraineeDetail.count } .by(1)
        end

        context "when there is an existing hesa_student record" do
          let(:student) do
            create(:hesa_student,
                   course_age_range: "13915",
                   itt_aim: "001",
                   itt_qualification_aim: "001",
                   fund_code: "7",
                   ni_number: "AB010203V",
                   previous_surname: "Jones",
                   bursary_level: Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY,
                   mode: "part_time",
                   year_of_course: 2026,
                   disability1: Hesa::CodeSets::Disabilities::MAPPING.keys.sample,
                   disability2: Hesa::CodeSets::Disabilities::MAPPING.keys.sample,
                   disability3: Hesa::CodeSets::Disabilities::MAPPING.keys.sample,
                   trainee: trainee)
          end

          it "uses attributes from the hesa_student record to fill nil values" do
            trainee.reload
            student.reload
            trainee.hesa_students

            subject.call(trainee:)
            trainee.reload

            %i[course_age_range itt_aim itt_qualification_aim fund_code pg_apprenticeship_start_date ni_number].each do |attribute|
              expect(trainee.hesa_trainee_detail.send(attribute)).to eq(student.send(attribute))
            end

            expect(trainee.hesa_trainee_detail.funding_method).to eq(student.bursary_level)
            expect(trainee.hesa_trainee_detail.previous_last_name).to eq(student.previous_surname)
            expect(trainee.hesa_trainee_detail.course_study_mode).to eq(student.mode)
            expect(trainee.hesa_trainee_detail.course_year).to eq(student.year_of_course.to_i)
            expect(trainee.hesa_trainee_detail.hesa_disabilities).to match([student.disability1, student.disability2, student.disability3])
          end
        end

        context "when there is an existing hesa_metadatum record" do
          let(:metadatum) { create(:hesa_metadatum, trainee:) }

          it "uses attributes from the hesa_metdatum record to fill nil values" do
            trainee.reload
            metadatum.reload
            subject.call(trainee:)
            trainee.reload

            %i[itt_aim itt_qualification_aim pg_apprenticeship_start_date].each do |attribute|
              expect(trainee.hesa_trainee_detail.send(attribute)).to eq(metadatum.send(attribute))
            end

            expect(trainee.hesa_trainee_detail.fund_code).to eq(metadatum.fundability)
          end
        end

        context "when there are existing hesa_metasatum and hesa_student records" do
          let(:student) do
            create(:hesa_student,
                   course_age_range: "13915",
                   itt_aim: "001",
                   itt_qualification_aim: "001",
                   fund_code: "7",
                   ni_number: "AB010203V",
                   bursary_level: Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY,
                   trainee: trainee)
          end

          let(:metadatum) { create(:hesa_metadatum, itt_aim: "002", itt_qualification_aim: "002", fundability: "3", trainee: trainee) }

          it "prioritises the values from the hesa_student record" do
            trainee.reload
            student.reload
            metadatum.reload
            subject.call(trainee:)
            trainee.reload

            %i[itt_aim itt_qualification_aim fund_code].each do |attribute|
              expect(trainee.hesa_trainee_detail.send(attribute)).to eq(student.send(attribute))
            end

            expect(trainee.hesa_trainee_detail.pg_apprenticeship_start_date).to eq(metadatum.pg_apprenticeship_start_date)
          end
        end
      end

      context "for a trainee with a hesa_trainee_detail record" do
        let(:trainee) { create(:trainee, :with_hesa_trainee_detail) }

        it "creates a hesa_trainee_detail record" do
          trainee.reload
          expect { subject.call(trainee:) } .not_to change { Hesa::TraineeDetail.count }
        end
      end
    end
  end
end
