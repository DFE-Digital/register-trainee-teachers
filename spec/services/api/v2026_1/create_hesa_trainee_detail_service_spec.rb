# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20261::CreateHesaTraineeDetailService do
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
                   training_initiative: Hesa::CodeSets::TrainingInitiatives::MAPPING.keys.sample,
                   trainee: trainee)
          end

          it "uses attributes from the hesa_student record to fill nil values" do
            trainee.reload
            student.reload
            trainee.hesa_students

            subject.call(trainee:)
            trainee.reload

            %i[course_age_range itt_aim itt_qualification_aim pg_apprenticeship_start_date ni_number].each do |attribute|
              expect(trainee.hesa_trainee_detail.send(attribute)).to eq(student.send(attribute))
            end

            expect(trainee.hesa_trainee_detail.funding_method).to eq(student.bursary_level)
            expect(trainee.hesa_trainee_detail.previous_last_name).to eq(student.previous_surname)
            expect(trainee.hesa_trainee_detail.course_study_mode).to eq(student.mode)
            expect(trainee.hesa_trainee_detail.course_year).to eq(student.year_of_course.to_i)
            expect(trainee.hesa_trainee_detail.hesa_disabilities).to match({ "disability1" => student.disability1, "disability2" => student.disability2, "disability3" => student.disability3 })
            expect(trainee.hesa_trainee_detail.additional_training_initiative).to eq(student.training_initiative)
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
          end
        end

        context "when there are existing hesa_metadatum and hesa_student records" do
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

            %i[itt_aim itt_qualification_aim].each do |attribute|
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

      context "when there is no hesa_student record" do
        context "with bursary fields set on the trainee" do
          let(:trainee) do
            create(:trainee,
                   applying_for_bursary: true,
                   applying_for_scholarship: false,
                   applying_for_grant: false,
                   bursary_tier: BURSARY_TIER_ENUMS[:tier_one])
          end

          it "sets funding_method from Trainees::MapFundingToHesa" do
            subject.call(trainee:)

            expect(trainee.reload.hesa_trainee_detail.funding_method)
              .to eq(Hesa::CodeSets::BursaryLevels::TIER_ONE)
          end
        end

        context "without any funding application from the trainee" do
          let(:trainee) do
            create(:trainee,
                   applying_for_bursary: false,
                   applying_for_scholarship: false,
                   applying_for_grant: false)
          end

          it "sets funding_method to NONE via Trainees::MapFundingToHesa" do
            subject.call(trainee:)

            expect(trainee.reload.hesa_trainee_detail.funding_method)
              .to eq(Hesa::CodeSets::BursaryLevels::NONE)
          end
        end
      end

      context "when a hesa_student bursary_level is present" do
        let(:trainee) do
          create(:trainee,
                 applying_for_bursary: true,
                 applying_for_scholarship: false,
                 applying_for_grant: false,
                 bursary_tier: BURSARY_TIER_ENUMS[:tier_one])
        end

        before do
          create(:hesa_student,
                 bursary_level: Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY,
                 trainee: trainee)
        end

        it "prefers the student record's bursary_level over the fallback" do
          subject.call(trainee:)

          expect(trainee.reload.hesa_trainee_detail.funding_method)
            .to eq(Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY)
        end
      end

      context "when the course_age_range is missing" do
        let(:trainee) { create(:trainee, course_min_age: 11, course_max_age: 16) }

        it "derives course_age_range from the trainee's range via Trainees::MapCourseAgeRangeToHesa" do
          subject.call(trainee:)

          expect(trainee.reload.hesa_trainee_detail.course_age_range).to eq("13918")
        end
      end

      context "when a hesa_student course_age_range is present" do
        let(:trainee) { create(:trainee, course_min_age: 11, course_max_age: 16) }

        before do
          create(:hesa_student, course_age_range: "13915", trainee: trainee)
        end

        it "prefers the student record's course_age_range over the fallback" do
          subject.call(trainee:)

          expect(trainee.reload.hesa_trainee_detail.course_age_range).to eq("13915")
        end
      end

      context "when hesa_disabilities is missing" do
        let(:trainee) { create(:trainee, :disabled) }

        before { trainee.disabilities << create(:disability, :learning_difficulty) }

        it "derives hesa_disabilities from the trainee's disabilities via Trainees::MapDisabilitiesToHesa" do
          subject.call(trainee:)

          expect(trainee.reload.hesa_trainee_detail.hesa_disabilities).to eq("disability1" => "51")
        end
      end

      context "when a hesa_student has disabilities" do
        let(:trainee) { create(:trainee, :disabled) }

        before do
          trainee.disabilities << create(:disability, :learning_difficulty)
          create(:hesa_student, disability1: "58", trainee: trainee)
        end

        it "prefers the student record's disabilities over the fallback" do
          subject.call(trainee:)

          expect(trainee.reload.hesa_trainee_detail.hesa_disabilities).to eq("disability1" => "58")
        end
      end
    end
  end
end
