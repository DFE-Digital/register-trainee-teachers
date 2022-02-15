# frozen_string_literal: true

require "rails_helper"

module Degrees
  describe CreateFromHesa do
    let(:hesa_api_stub) { ApiStubs::HesaApi.new({}) }
    let(:student_attributes) { hesa_api_stub.student_attributes }

    let(:trainee) { create(:trainee, hesa_id: student_attributes[:hesa_id]) }
    let(:hesa_degrees) { student_attributes[:degrees] }

    subject(:create_from_hesa) { described_class.call(trainee: trainee, hesa_degrees: hesa_degrees) }

    shared_examples "invalid" do
      it "does not save the degree" do
        expect { create_from_hesa }.not_to change(trainee.degrees, :count)
      end
    end

    context "update trainee with HESA xml" do
      before do
        create_from_hesa
      end

      it "creates a degree against the provided trainee" do
        expect(trainee.degrees.count).to eq(student_attributes[:degrees].count)
        degree = trainee.degrees.first
        hesa_degree = student_attributes[:degrees].first
        expect(degree.locale_code).to eq("non_uk")
        expect(degree.uk_degree).to be_nil
        expect(degree.non_uk_degree).to eq("Unknown")
        expect(degree.subject).to eq(hesa_degree[:subject])
        expect(degree.institution).to eq("The Open University")
        expect(degree.graduation_year).to eq(2005)
        expect(degree.grade).to eq("First-class honours")
        expect(degree.other_grade).to be_nil
        expect(degree.country).to eq("Canada")
      end
    end
  end
end
