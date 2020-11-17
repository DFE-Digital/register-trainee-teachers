# frozen_string_literal: true

require "rails_helper"

module Diversities
  module EthnicGroups
    describe Update do
      describe ".call" do
        let(:service) { described_class.new(trainee: trainee, attributes: attributes) }

        context "when ethnic group attribute is valid" do
          let(:trainee) { create(:trainee) }
          let(:attributes) { { ethnic_group: Diversities::ETHNIC_GROUP_ENUMS.values.sample } }

          before do
            service.call
            trainee.reload
          end

          it "updates the trainee's ethnic group details" do
            expect(trainee.ethnic_group).to be_truthy
            expect(trainee.ethnic_group).to eq(attributes[:ethnic_group])
          end

          it "is successful" do
            expect(service).to be_successful
          end
        end

        context "when attributes contain a new ethnic group value" do
          let(:trainee) do
            create(
              :trainee,
              ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:asian],
              ethnic_background: "some background",
              additional_ethnic_background: "some other background",
            )
          end

          let(:attributes) { { ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:mixed] } }

          before do
            service.call
            trainee.reload
          end

          it "resets the trainee's previous ethnic background details" do
            expect(trainee.ethnic_background).to be_nil
            expect(trainee.additional_ethnic_background).to be_nil
          end

          it "is successful" do
            expect(service).to be_successful
          end
        end

        context "when ethnic group attribute is invalid" do
          let(:trainee) { create(:trainee) }
          let(:attributes) { { ethnic_group: nil } }

          before do
            service.call
            trainee.reload
          end

          it "does not update the trainee's ethnic group details" do
            expect(trainee.ethnic_group).to be_truthy
          end

          it "is unsuccessful" do
            expect(service).to_not be_successful
          end
        end
      end
    end
  end
end
