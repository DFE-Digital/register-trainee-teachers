# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20250Rc::CreateHesaTraineeDetailService do
  subject { described_class }

  describe "::call" do
    describe "success" do
      context "for a trainee without a hesa_trainee_detail record" do
        let(:trainee) { create(:trainee) }

        it "creates a hesa_trainee_detail record" do
          trainee.reload
          expect { subject.call(trainee:) } .to change { Hesa::TraineeDetail.count } .by(1)
        end

        context "when there is an existing hesa_student record" do
          let(:student) { create(:hesa_student, course_age_range: "13915", itt_aim: "001", itt_qualification_aim: "001", fund_code: "7", ni_number: "AB010203V", trainee: trainee) }

          it "uses attributes from the hesa_student record to fill nil values" do
            trainee.reload
            student.reload
            trainee.hesa_students

            subject.call(trainee:)
            trainee.reload

            %i[course_age_range itt_aim itt_qualification_aim fund_code pg_apprenticeship_start_date ni_number].each do |attribute|
              expect(trainee.hesa_trainee_detail.send(attribute)).to eq(student.send(attribute))
            end
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
