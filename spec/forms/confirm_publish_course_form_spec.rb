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
    let(:course) { create(:course) }
    let(:params) { { code: course.code } }

    context "valid trainee" do
      let(:trainee) { create(:trainee) }

      describe "#save" do
        it "changed related trainee attributes" do
          expect { subject.save }
            .to change { trainee.subject }
            .from(nil).to(course.name)
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

    context "when trainee is assigned to multiple subjects" do
      let(:trainee) { create(:trainee, :with_multiple_subjects) }

      it "removed the surplus subjects on save" do
        expect { subject.save }
            .to change { trainee.subject_two }
            .from(trainee.subject_two).to(nil)
            .and change { trainee.subject_three }
            .from(trainee.subject_three).to(nil)
      end
    end
  end
end
