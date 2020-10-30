require "rails_helper"

module Diversities
  module DisabilityDisclosures
    describe Update do
      describe ".call" do
        let(:trainee) { create(:trainee, disability_disclosure: nil) }
        let(:service) { described_class.new(trainee: trainee, attributes: attributes) }

        before(:each) do
          service.call
          trainee.reload
        end

        context "when disability disclosure attribute is valid" do
          let(:attributes) { { disability_disclosure: DISABILITY_DISCLOSURE_ENUMS[:disabled] } }

          it "updates the trainee's disclosure details" do
            expect(trainee.disability_disclosure).to be_truthy
            expect(trainee.disability_disclosure).to eq(attributes[:disability_disclosure])
          end

          it "is successful" do
            expect(service).to be_successful
          end
        end

        context "when disability disclosure attribute is invalid" do
          let(:attributes) { { disability_disclosure: nil } }

          it "does not update the trainee's disclosure details" do
            expect(trainee.disability_disclosure).to be_falsey
          end

          it "is unsuccessful" do
            expect(service).to_not be_successful
          end
        end
      end
    end
  end
end
