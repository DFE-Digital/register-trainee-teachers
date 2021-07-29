# frozen_string_literal: true

require "rails_helper"

describe CalculateSubjectSpecialisms do
  subject { described_class.call(subjects: subjects) }

  context "publish course has one subject" do
    let(:subjects) { %w[Chemistry] }

    context "subject has many subject specialisms" do
      it "only sets one attribute so the user can choose which specialism later" do
        expect(subject).to match({
          course_subject_one: ["chemistry", "applied chemistry"],
          course_subject_two: [],
          course_subject_three: [],
        })
      end
    end

    context "publish course has one primary subject with other topics" do
      context "one other subject" do
        let(:subjects) { ["Primary with modern languages"] }

        it "fills the first two attributes with the respective specialism" do
          expect(subject).to match({
            course_subject_one: ["primary teaching"],
            course_subject_two: ["modern languages"],
            course_subject_three: [],
          })
        end
      end

      context "two other subjects" do
        let(:subjects) { ["Primary with geography and history"] }

        it "fills all three attributes with the respective specialism" do
          expect(subject).to match({
            course_subject_one: ["primary teaching"],
            course_subject_two: %w[geography],
            course_subject_three: %w[history],
          })
        end
      end
    end
  end

  context "publish course is modern languages" do
    context "Modern Languages (German)" do
      let(:subjects) { ["German", "Modern languages (other)"] }

      it "fills one attribute with the respective language specialism and ignores modern language" do
        expect(subject).to match({
          course_subject_one: ["German language"],
          course_subject_two: [],
          course_subject_three: [],
        })
      end
    end

    context "German and/or French" do
      let(:subjects) { %w[German French] }

      it "fills one attribute with the respective specialisms so the use can choose one or both" do
        expect(subject).to match({
          course_subject_one: ["German language", "French language"],
          course_subject_two: [],
          course_subject_three: [],
        })
      end
    end

    context "several languages" do
      let(:subjects) { ["French", "German", "Italian", "Mandarin", "Modern Languages", "Spanish"] }

      it "only sets one attribute but ignores Modern Languages" do
        expect(subject).to match({
          course_subject_one: [
            "French language",
            "German language",
            "Italian language",
            "Chinese languages",
            "Spanish language",
          ],
          course_subject_two: [],
          course_subject_three: [],
        })
      end
    end
  end

  context "course with different subjects where one has multiple specialisms" do
    let(:subjects) { %w[Drama English] }

    it "returns a hash with values for course_subject_one and course_subject_two" do
      expect(subject).to match({
        course_subject_one: ["drama", "performing arts"],
        course_subject_two: ["English studies"],
        course_subject_three: [],
      })
    end
  end
end
