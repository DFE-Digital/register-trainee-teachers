# frozen_string_literal: true

require "rails_helper"

describe ConfirmPublishCourseForm, feature_course_study_mode: true, type: :model do
  let(:params) { {} }
  let(:trainee) { build(:trainee) }
  let(:specialisms) { [] }
  let(:itt_start_date) { nil }
  let(:course_study_mode) { nil }

  subject { described_class.new(trainee, specialisms, itt_start_date, course_study_mode, params) }

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
    let(:specialisms) do
      [
        subject_specialism_one,
        subject_specialism_two,
        subject_specialism_three,
      ]
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

      context "with itt_start_date set" do
        let(:itt_start_date) { Time.zone.today }

        it "updates all the course related attributes and itt_start_date" do
          expect { subject.save }
            .to change { trainee.course_start_date }
            .from(nil).to(itt_start_date)
        end
      end

      context "with study_mode set" do
        let(:course_study_mode) { "full_time" }

        it "updates all the course related attributes and study_mode" do
          expect { subject.save }
            .to change { trainee.study_mode }
            .from(nil).to(course_study_mode)
        end
      end

      context "when the course_subject has changed" do
        let(:progress) { Progress.new(course_details: true, funding: true, personal_details: true) }
        let(:trainee) { build(:trainee, applying_for_bursary: true, progress: progress) }

        it "nullifies the bursary information and resets funding section progress" do
          expect { subject.save }
          .to change { trainee.applying_for_bursary }
          .from(true).to(nil)
          .and change { trainee.progress.funding }
          .from(true).to(false)
        end
      end
    end
  end
end
