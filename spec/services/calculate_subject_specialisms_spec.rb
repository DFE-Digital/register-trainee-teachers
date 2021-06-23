# frozen_string_literal: true

require "rails_helper"

describe CalculateSubjectSpecialisms do
  before do
    stub_const("PUBLISH_SUBJECT_SPECIALISM_MAPPING", subject_specialism_mapping)
  end

  subject { described_class.call(subjects: subjects) }

  context "course has one subject" do
    let(:subjects) { %w[Chemistry] }

    context "subject has many subject specialisms" do
      let(:subject_specialism_mapping) do
        { "Chemistry" => ["chemistry", "applied chemistry"] }
      end

      it "returns a hash with values for course_subject_one" do
        expect(subject).to match({
          course_subject_one: ["chemistry", "applied chemistry"],
          course_subject_two: [],
          course_subject_three: [],
        })
      end
    end

    context "course has one Primary subject" do
      let(:subjects) { ["Primary with geography and history"] }

      let(:subject_specialism_mapping) do
        { "Primary with geography and history" => ["primary teaching", "geography", "history"] }
      end

      it "returns a hash with values for course_subject_one, course_subject_two and course_subject_three" do
        expect(subject).to match({
          course_subject_one: ["primary teaching"],
          course_subject_two: %w[geography],
          course_subject_three: %w[history],
        })
      end
    end
  end

  context "course subject is modern languages" do
    let(:subjects) { %w[German French] }

    let(:subject_specialism_mapping) do
      { "German" => ["German language"], "French" => ["French language"] }
    end

    it "returns a hash with values for course_subject_one" do
      expect(subject).to match({
        course_subject_one: ["German language", "French language"],
        course_subject_two: [],
        course_subject_three: [],
      })
    end
  end

  context "course with different subjects" do
    let(:subjects) { %w[Drama English] }

    let(:subject_specialism_mapping) do
      { "Drama" => ["Drama", "Performing Arts"], "English" => ["English Studies"] }
    end

    it "returns a hash with values for course_subject_one and course_subject_two" do
      expect(subject).to match({
        course_subject_one: ["Drama", "Performing Arts"],
        course_subject_two: ["English Studies"],
        course_subject_three: [],
      })
    end
  end
end
