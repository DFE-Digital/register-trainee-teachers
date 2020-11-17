# frozen_string_literal: true

require "rails_helper"

module Diversities
  module Disclosures
    describe Update do
      describe ".call" do
        let(:trainee) { create(:trainee, diversity_disclosure: nil) }
        let(:service) { described_class.new(trainee: trainee, attributes: attributes) }

        before(:each) do
          service.call
          trainee.reload
        end

        context "when disclosure attribute is valid" do
          let(:attributes) { { diversity_disclosure: DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed] } }

          it "updates the trainee's disclosure details" do
            expect(trainee.diversity_disclosure).to be_truthy
            expect(trainee.diversity_disclosure).to eq(attributes[:diversity_disclosure])
          end

          it "is successful" do
            expect(service).to be_successful
          end
        end

        context "when disclosure attribute is invalid" do
          let(:attributes) { { diversity_disclosure: nil } }

          it "does not update the trainee's disclosure details" do
            expect(trainee.diversity_disclosure).to be_falsey
          end

          it "is unsuccessful" do
            expect(service).to_not be_successful
          end
        end
      end
    end
  end
end
