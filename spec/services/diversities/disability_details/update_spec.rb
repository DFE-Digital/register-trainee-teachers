require "rails_helper"

module Diversities
  module DisabilityDetails
    describe Update do
      describe ".call" do
        let(:trainee) { create(:trainee) }
        let(:disability) { create(:disability) }
        let(:service) { described_class.new(trainee: trainee, attributes: attributes) }

        before(:each) do
          service.call
          trainee.reload
        end

        context "when disabilty detail attributes are valid" do
          let(:attributes) { { disability_ids: [disability.id] } }

          it "updates the trainee's disabilities" do
            expect(trainee.disabilities).to include(disability)
          end

          it "is successful" do
            expect(service).to be_successful
          end
        end

        context "when disabilty detail attributes are invalid" do
          let(:attributes) { { disability_ids: nil } }

          it "does not update the trainee's disabilities" do
            expect(trainee.disabilities).to be_empty
          end

          it "is unsuccessful" do
            expect(service).to_not be_successful
          end
        end
      end
    end
  end
end
