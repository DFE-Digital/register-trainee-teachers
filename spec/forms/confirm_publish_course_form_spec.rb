# frozen_string_literal: true

require "rails_helper"

describe ConfirmPublishCourseForm, type: :model do
  let(:params) { {} }
  let(:trainee) { create(:trainee) }
  subject { described_class.new(trainee, params) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:code) }
  end

  context "with valid params" do
    let(:course) { create(:course_with_subjects, subject_names: subjects) }
    let(:params) { { code: course.code } }
    let(:subjects) { ["Subject 1", "Subject 2", "Subject 3"] }

    let(:subject_specialism_one) { "Subject specialism 1" }
    let(:subject_specialism_two) { "Subject specialism 2" }
    let(:subject_specialism_three) { "Subject specialism 3" }

    before do
      allow(CalculateSubjectSpecialisms).to(
        receive(:call).with(subjects: subjects).and_return(
          {
            course_subject_one: [subject_specialism_one],
            course_subject_two: [subject_specialism_two],
            course_subject_three: [subject_specialism_three],
          },
        ),
      )
    end

    describe "#save" do
      it "updates all the course related attributes" do
        expect { subject.save }
          .to change { trainee.course_subject_one }
          .from(nil).to(subject_specialism_one)
          .and change { trainee.course_subject_two }
          .from(nil).to(subject_specialism_two)
          .and change { trainee.course_subject_three }
          .from(nil).to(subject_specialism_three)
          .and change { trainee.course_min_age }
          .from(nil).to(course.min_age)
          .and change { trainee.course_max_age }
          .from(nil).to(course.max_age)
          .and change { trainee.course_start_date }
          .from(nil).to(course.start_date)
          .and change { trainee.course_end_date }
          .from(nil).to((course.start_date + course.duration_in_years.years).to_date.prev_day)
      end
    end
  end
end
