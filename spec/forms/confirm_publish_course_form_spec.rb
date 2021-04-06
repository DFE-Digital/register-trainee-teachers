# frozen_string_literal: true

require "rails_helper"

describe ConfirmPublishCourseForm, type: :model do
  let(:params) { {} }
  let(:trainee) { build(:trainee) }
  subject { described_class.new(trainee, params) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:code) }
  end

  context "valid trainee" do
    let(:course) { create(:course) }
    let(:params) { { code: course.code } }
    let(:trainee) { create(:trainee) }
    subject { described_class.new(trainee, params) }

    describe "#save" do
      it "changed related trainee attributes" do
        expect { subject.save }
          .to change { trainee.subject }
          .from(nil).to(course.name)
          .and change { trainee.age_range }
          .from(nil).to(course.age_range)
          .and change { trainee.course_start_date }
          .from(nil).to(course.start_date)
          .and change { trainee.course_end_date }
          .from(nil).to((course.start_date + course.duration_in_years.years).to_date.prev_day)
      end
    end
  end
end
