# frozen_string_literal: true

require "rails_helper"

module Degrees
  describe CreateFromHesa do
    let(:hesa_api_stub) { ApiStubs::HesaApi.new }
    let(:student_attributes) { hesa_api_stub.student_attributes }
    let(:trainee) { create(:trainee, hesa_id: student_attributes[:hesa_id]) }
    let(:hesa_degrees) { student_attributes[:degrees] }

    subject(:create_from_hesa) do
      described_class.call(trainee: trainee, hesa_degrees: hesa_degrees)
    end

    shared_examples "invalid" do
      it "does not save the degree" do
        expect { create_from_hesa }.not_to change(trainee.degrees, :count)
      end
    end

    context "update trainee with HESA XML" do
      let(:degree) { trainee.degrees.first }
      let(:hesa_degree) { student_attributes[:degrees].first }

      before { create_from_hesa }

      it "creates the exact number of degrees as specified in the XML" do
        expect(trainee.degrees.count).to eq(student_attributes[:degrees].count)
      end

      context "UK degree" do
        it "sets UK attributes only" do
          expect(degree.locale_code).to eq("uk")
          expect(degree.uk_degree).to eq("Unknown")
          expect(degree.non_uk_degree).to be_nil
          expect(degree.subject).to eq(hesa_degree[:subject])
          expect(degree.institution).to eq("The Open University")
          expect(degree.graduation_year).to eq(2005)
          expect(degree.grade).to eq("First-class honours")
          expect(degree.other_grade).to be_nil
          expect(degree.country).to be_nil
          expect(degree.institution_uuid).to eq("5c9e1d2d-3fa2-e811-812b-5065f38ba241")
        end
      end

      context "UK country code but no institution reference" do
        let(:hesa_degrees) do
          [
            {
              graduation_date: "2003-06-01",
              degree_type: "400",
              subject: "100485",
              institution: nil,
              grade: "02",
              country: "XF",
            },
          ]
        end

        it "sets UK attributes with nil institution and institution_uuid" do
          expect(degree.locale_code).to eq("uk")
          expect(degree.uk_degree).to eq("First Degree")
          expect(degree.non_uk_degree).to be_nil
          expect(degree.subject).to eq("Law")
          expect(degree.institution).to be_nil
          expect(degree.graduation_year).to eq(2003)
          expect(degree.grade).to eq("Upper second-class honours (2:1)")
          expect(degree.other_grade).to be_nil
          expect(degree.country).to be_nil
          expect(degree.institution_uuid).to be_nil
        end
      end

      context "Non-UK degree" do
        let(:hesa_degrees) do
          [{
            graduation_date: "2004-12-01",
            degree_type: "205",
            subject: "100403",
            institution: nil,
            grade: "14",
            country: "IN",
          }]
        end

        it "sets non-UK attributes only" do
          expect(degree.locale_code).to eq("non_uk")
          expect(degree.uk_degree).to be_nil
          expect(degree.non_uk_degree).to eq("Master of Science")
          expect(degree.subject).to eq("Mathematics")
          expect(degree.institution).to be_nil
          expect(degree.graduation_year).to eq(2004)
          expect(degree.grade).to eq("Pass")
          expect(degree.other_grade).to be_nil
          expect(degree.country).to eq("India")
        end
      end
    end
  end
end
