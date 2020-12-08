# frozen_string_literal: true

require "rails_helper"

module Diversities
  module EthnicBackgrounds
    describe Update do
      describe ".call" do
        let(:trainee) { create(:trainee, ethnic_background: nil, additional_ethnic_background: nil) }
        let(:service) { described_class.call(trainee: trainee, attributes: attributes) }

        before(:each) do
          service.call
          trainee.reload
        end

        context "when ethnic background attributes are valid" do
          let(:attributes) do
            {
              ethnic_background: "Another ethnic background",
              additional_ethnic_background: "some other background",
            }
          end

          it "updates the trainee's ethnic background details" do
            expect(trainee.ethnic_background).to eq(attributes[:ethnic_background])
            expect(trainee.additional_ethnic_background).to eq(attributes[:additional_ethnic_background])
          end

          it "is successful" do
            expect(service).to be_successful
          end
        end

        context "when ethnic background attributes are invalid" do
          let(:attributes) { { ethnic_background: nil } }

          it "does not update the trainee's ethnic background details" do
            expect(trainee.ethnic_background).to be_falsey
          end

          it "is unsuccessful" do
            expect(service).to_not be_successful
          end
        end
      end
    end
  end
end
