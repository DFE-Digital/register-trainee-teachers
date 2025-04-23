# frozen_string_literal: true

require "rails_helper"

module Degrees
  describe CreateFromHesa do
    let(:hesa_api_stub) { ApiStubs::HesaApi.new }
    let(:student_attributes) { hesa_api_stub.student_attributes }
    let(:trainee) { create(:trainee, hesa_id: student_attributes[:hesa_id]) }
    let(:hesa_degrees) { student_attributes[:degrees] }

    subject(:create_from_hesa) do
      described_class.call(trainee:, hesa_degrees:)
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

      context "UK country code but no institution reference" do
        let(:hesa_degrees) do
          [
            {
              graduation_date: "2003-06-01",
              degree_type: "400",
              subject_one: "100485",
              institution: nil,
              grade: "02",
              country: "XF",
            },
          ]
        end

        it "creates a UK degree with 'other' institution and institution_uuid" do
          expect(degree.locale_code).to eq("uk")
          expect(degree.uk_degree).to eq("First Degree")
          expect(degree.non_uk_degree).to be_nil
          expect(degree.subject).to eq("Law")
          expect(degree.institution).to eq("Other UK institution")
          expect(degree.graduation_year).to eq(2003)
          expect(degree.grade).to eq("Upper second-class honours (2:1)")
          expect(degree.other_grade).to be_nil
          expect(degree.country).to be_nil
          expect(degree.institution_uuid).to eq("02132969-f5bc-47ca-be9c-b6f6d5b05e1b")
        end
      end

      context "No country and no institution" do
        let(:hesa_degrees) do
          [
            {
              graduation_date: "2003-06-01",
              degree_type: "400",
              subject_one: "100485",
              institution: nil,
              grade: "02",
              country: nil,
            },
          ]
        end

        it "creates a UK degree with other institution and institution_uuid" do
          expect(degree.locale_code).to eq("uk")
          expect(degree.uk_degree).to eq("First Degree")
          expect(degree.non_uk_degree).to be_nil
          expect(degree.subject).to eq("Law")
          expect(degree.institution).to eq("Other UK institution")
          expect(degree.graduation_year).to eq(2003)
          expect(degree.grade).to eq("Upper second-class honours (2:1)")
          expect(degree.other_grade).to be_nil
          expect(degree.country).to be_nil
          expect(degree.institution_uuid).to eq("02132969-f5bc-47ca-be9c-b6f6d5b05e1b")
        end
      end

      context "institution but no UK country code" do
        let(:hesa_degrees) do
          [
            {
              graduation_date: "2003-06-01",
              degree_type: "400",
              subject_one: "100485",
              institution: "0429",
              grade: "02",
              country: nil,
            },
          ]
        end

        it "creates a UK degree" do
          expect(degree.locale_code).to eq("uk")
          expect(degree.uk_degree).to eq("First Degree")
          expect(degree.non_uk_degree).to be_nil
          expect(degree.subject).to eq("Law")
          expect(degree.institution).to eq("Raindance Educational Services")
          expect(degree.graduation_year).to eq(2003)
          expect(degree.grade).to eq("Upper second-class honours (2:1)")
          expect(degree.other_grade).to be_nil
          expect(degree.country).to be_nil
          expect(degree.institution_uuid).to eq("bb3e182c-1425-ec11-b6e6-000d3adf095a")
        end

        context "non-awarding institution" do
          let(:hesa_degrees) do
            [
              {
                graduation_date: "2003-06-01",
                degree_type: "400",
                subject_one: "100485",
                institution: "1000",
                grade: "02",
                country: nil,
              },
            ]
          end

          it "sets the institution to 'other'" do
            expect(degree.institution).to eq("Other UK institution")
            expect(degree.institution_uuid).to eq("02132969-f5bc-47ca-be9c-b6f6d5b05e1b")
          end
        end
      end

      context "institution is Institute of Education (0133)" do
        let(:hesa_degrees) do
          [
            {
              graduation_date: "2003-06-01",
              degree_type: "400",
              subject_one: "100485",
              institution: "0133",
              grade: "02",
              country: nil,
            },
          ]
        end

        it "remaps it to University College London (0149)" do
          expect(degree.institution).to eq("University College London")
        end
      end

      context "Non-UK degree" do
        let(:hesa_degrees) do
          [{
            graduation_date: "2004-12-01",
            degree_type: "205",
            subject_one: "100403",
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

      context "degree type 999" do
        context "and all other values are nil" do
          let(:hesa_degrees) do
            [
              {
                graduation_date: nil,
                degree_type: "999",
                subject_one: nil,
                institution: nil,
                grade: nil,
                country: nil,
              },
            ]
          end

          it "saves the degree" do
            subject

            expect(trainee.degrees.count).to eq(1)
          end
        end

        context "and at least one other value present" do
          let(:hesa_degrees) do
            [
              {
                graduation_date: nil,
                degree_type: "999",
                subject_one: nil,
                institution: nil,
                grade: "14",
                country: nil,
              },
            ]
          end

          it "saves the degree" do
            subject

            expect(trainee.degrees.count).to eq(1)
            expect(degree.grade).to eq("Pass")
          end
        end
      end

      context "handling honours degree types" do
        let(:hesa_degrees) do
          [
            {
              graduation_date: "2003-06-01",
              degree_type: "007",
              subject_one: "100485",
              institution: "00429",
              grade: "02",
              country: nil,
            },
          ]
        end

        it "maps the honours HESA code to a non-honours HESA code" do
          expect(degree.uk_degree).to eq("Bachelor of Arts in Education")
          expect(degree.uk_degree_uuid).to eq("007a0999-87f7-4afc-8ccd-ce1e1d92c9ac")
        end
      end
    end
  end
end
