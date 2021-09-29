# frozen_string_literal: true

require "rails_helper"

describe CourseEducationPhaseForm, type: :model do
  let(:params) { {} }
  let(:trainee) { build(:trainee) }

  subject { described_class.new(trainee, params: params) }

  describe "validations" do
    context "course_education_phase is nil" do
      before { subject.validate }

      it "is missing" do
        expect(subject.errors[:course_education_phase]).to include(
          I18n.t(
            "activemodel.errors.models.course_education_phase_form.attributes.course_education_phase.blank",
          ),
        )
      end
    end
  end

  describe "#save!" do
    let(:trainee) { create(:trainee, :with_course_details_and_study_mode) }

    let(:params) do
      {
        course_education_phase: COURSE_EDUCATION_PHASE_ENUMS[:secondary],
      }
    end

    it "clears out the trainee course subject" do
      expect {
        subject.save!
      }.to change { subject.trainee.course_subject_one }
       .from(subject.trainee.course_subject_one).to(nil)
       .and change { subject.trainee.course_age_range }
       .from(subject.trainee.course_age_range).to([])
    end

    context "when the education phase is not changed" do
      let(:trainee) { create(:trainee, :with_course_details_and_study_mode, :with_secondary_education) }

      it "does not clear out the course subject" do
        subject.save!
        expect(trainee.reload.course_subject_one).not_to be_nil
      end
    end
  end
end
