# frozen_string_literal: true

require "rails_helper"

describe ConfirmPublishCourseForm, type: :model do
  let(:params) { {} }
  let(:trainee) { build(:trainee) }
  subject { described_class.new(trainee, params) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:code) }
  end

  context "with valid params" do
    subject { described_class.new(trainee, params) }
    let(:course) { create(:course_with_subjects) }
    let(:params) { { code: course.code } }

    context "valid trainee" do
      let(:trainee) { create(:trainee) }

      describe "#save" do
        it "changed related trainee attributes" do
          expect { subject.save }
            .to change { trainee.course_subject_one }
            .from(nil).to(course.subject_one.name)
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

    context "when course has multiple subjects" do
      context "with two subjects" do
        let(:course) { create(:course_with_subjects, subjects_count: 2) }

        it "stores the second subject" do
          expect { subject.save }
            .to change { trainee.course_subject_two }
            .from(nil).to(course.subject_two.name)
        end
      end

      context "with three subjects" do
        let(:course) { create(:course_with_subjects, subjects_count: 3) }

        it "stores the third subject" do
          expect { subject.save }
            .to change { trainee.course_subject_three }
            .from(nil).to(course.subject_three.name)
        end
      end
    end
  end
end
