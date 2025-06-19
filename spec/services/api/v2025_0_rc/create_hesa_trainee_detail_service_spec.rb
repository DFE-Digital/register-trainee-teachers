
require "rails_helper"

RSpec.describe Api::V20250Rc::CreateHesaTraineeDetailService do
  subject { described_class }

  describe "::call" do
    describe "success" do
      context "for a trainee without a hesa_trainee_detail record" do
        let(:trainee) { create(:trainee, :with_hesa_student) }
        let(:metadatum) { create(:metadatum, trainee:) }

        it "creates a hesa_trainee_detail record" do
          trainee.reload
          expect { subject.call(trainee:) } .to change { Hesa::TraineeDetail.count } .by(1)
        end
      end

      context "for a trainee with a hesa_trainee_detail record" do
        let(:trainee) { create(:trainee, :with_hesa_trainee_detail) }

        it "creates a hesa_trainee_detail record" do
          trainee.reload
          expect { subject.call(trainee:) } .to change { Hesa::TraineeDetail.count } .by(0)
        end
      end
    end
  end
end
