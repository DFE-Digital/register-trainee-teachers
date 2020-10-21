require "rails_helper"

module Diversities
  module EthnicGroups
    describe Update do
      describe ".call" do
        let(:trainee) { create(:trainee, ethnic_group: nil) }
        let(:service) { described_class.new(trainee: trainee, attributes: attributes) }

        before(:each) do
          service.call
          trainee.reload
        end

        context "when ethnic group attribute is valid" do
          let(:attributes) { { ethnic_group: Trainee.ethnic_groups.keys.sample } }

          it "updates the trainee's ethnic group details" do
            expect(trainee.ethnic_group).to be_truthy
            expect(trainee.ethnic_group).to eq(attributes[:ethnic_group])
          end

          it "is successful" do
            expect(service).to be_successful
          end
        end

        context "when ethnic group attribute is invalid" do
          let(:attributes) { { ethnic_group: nil } }

          it "does not update the trainee's ethnic group details" do
            expect(trainee.ethnic_group).to be_falsey
          end

          it "is unsuccessful" do
            expect(service).to_not be_successful
          end
        end
      end
    end
  end
end
