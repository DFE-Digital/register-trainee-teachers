# frozen_string_literal: true

require "rails_helper"

module Degrees
  describe FixToMatchReferenceData do
    let(:degree) { create(:degree, institution: institution, uk_degree: type, subject: subject_name, grade: grade) }
    let(:institution) { "The Open University" }
    let(:type) { "Foundation of Arts" }
    let(:subject_name) { "English studies" }
    let(:grade) { "First-class honours" }

    subject { described_class.call(degree: degree) }

    describe "institution" do
      context "value is correct" do
        it "is left unchanged" do
          expect(subject).to eq(degree)
        end
      end

      context "value is incorrect" do
        context "match is found in reference data" do
          let(:institution) { "The University of Chichester" }

          it "is updated" do
            expect(subject.institution).to eq("University of Chichester")
          end
        end

        context "match isn't found in reference data" do
          let(:institution) { "Chorley Wetherspoons" }

          it "is left unchanged" do
            expect(subject.institution).to eq(institution)
          end
        end
      end
    end

    describe "type" do
      context "value is correct" do
        it "is left unchanged" do
          expect(subject).to eq(degree)
        end
      end

      context "value is incorrect" do
        context "match is found in reference data with different casing" do
          let(:type) { "Foundation of arts" }

          it "is updated" do
            expect(subject.uk_degree).to eq("Foundation of Arts")
          end
        end

        context "match isn't found in reference data" do
          let(:type) { "Dodgy qualification off of the intewebs" }

          it "is left unchanged" do
            expect(subject.uk_degree).to eq(type)
          end
        end
      end
    end

    describe "subject" do
      context "value is correct" do
        it "is left unchanged" do
          expect(subject).to eq(degree)
        end
      end

      context "value is incorrect" do
        context "match is found in reference data with different casing" do
          let(:subject_name) { "English Studies" }

          it "is updated" do
            expect(subject.subject).to eq("English studies")
          end
        end

        context "match isn't found in reference data" do
          let(:subject_name) { "Harry Styles studies" }

          it "is left unchanged" do
            expect(subject.subject).to eq(subject_name)
          end
        end
      end
    end

    describe "grade" do
      context "value is correct" do
        it "is left unchanged" do
          expect(subject).to eq(degree)
        end
      end

      context "value is incorrect" do
        context "match is found in reference data" do
          let(:grade) { "First class honours" }

          it "is updated" do
            expect(subject.grade).to eq("First-class honours")
          end
        end

        context "match isn't found in reference data" do
          let(:grade) { "Epic fail" }

          it "is left unchanged" do
            expect(subject.grade).to eq(grade)
          end
        end
      end
    end
  end
end
