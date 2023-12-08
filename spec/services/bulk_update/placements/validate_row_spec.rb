# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module Placements
    describe ValidateRow do
      subject(:service) { described_class.new(placement_row) }

      let(:placement_row) { double("PlacementRow", urn:) }

      describe "#valid?" do
        context "when the urn format is valid and the school exists" do
          let(:urn) { school.urn }
          let(:school) { create(:school) }

          it "is valid" do
            expect(service).to be_valid
            expect(service.school).to eql school
          end
        end

        context "when the urn format is invalid" do
          let(:urn) { "invalid_urn" }

          it "is not valid and has the correct error message" do
            expect(service).not_to be_valid
            expect(service.error_messages).to include match(/URN must be 6 numbers/)
          end
        end

        context "when the school does not exist" do
          let(:urn) { "123456" }

          it "is not valid and has the correct error message" do
            expect(service).not_to be_valid
            expect(service.error_messages).to include match(/No School was found for URN 123456/)
          end
        end
      end
    end
  end
end
