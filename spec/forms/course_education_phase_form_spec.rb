# frozen_string_literal: true

require "rails_helper"

describe CourseEducationPhaseForm, type: :model do
  let(:trainee) { build(:trainee) }

  subject { described_class.new(trainee) }

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
end
