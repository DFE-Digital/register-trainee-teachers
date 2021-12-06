# frozen_string_literal: true

require "rails_helper"

module Dttp
  module Parsers
    describe DegreeQualification do
      describe "#to_attributes" do
        let(:degree_qualification) { create(:api_degree_qualification) }

        let(:expected_attributes) do
          {
            dttp_id: degree_qualification["dfe_degreequalificationid"],
            contact_dttp_id: degree_qualification["_dfe_contactid_value"],
            response: degree_qualification,
          }
        end

        subject { described_class.to_attributes(degree_qualifications: [degree_qualification]) }

        it "returns an array of Dttp::DegreeQualification attributes" do
          expect(subject).to eq([expected_attributes])
        end
      end
    end
  end
end
