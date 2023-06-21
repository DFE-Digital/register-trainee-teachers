# frozen_string_literal: true

require "rails_helper"

describe LanguageSpecialismsForm, type: :model do
  let(:params) { {} }
  let(:trainee) { build(:trainee) }
  let(:form_store) { class_double(FormStore) }

  subject { described_class.new(trainee, params: params, store: form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
  end

  describe "validations" do
    context "when no subjects are supplied" do
      let(:params) { { course_subject_one: nil, course_subject_two: nil, course_subject_three: nil } }

      before do
        subject.valid?
      end

      it "returns an error" do
        expect(subject.errors[:course_subject_one]).to include(
          I18n.t(
            "activemodel.errors.models.language_specialisms_form.attributes.course_subject_one.blank",
          ),
        )
      end
    end

    context "when there are duplicate subjects" do
      let(:params) { { course_subject_one: "French language", course_subject_two: "German language", course_subject_three: "French language" } }

      before do
        subject.valid?
      end

      it "returns an error" do
        expect(subject.errors[:course_subject_one]).to include(
          I18n.t(
            "activemodel.errors.models.language_specialisms_form.attributes.course_subject_one.invalid",
          ),
        )
      end
    end
  end

  context "valid trainee" do
    let(:params) { { course_subject_one: "French language", course_subject_two: "German language", course_subject_three: "Spanish language" } }

    let(:trainee) { create(:trainee) }

    describe "#stash" do
      let(:fields) { params }

      it "uses FormStore to temporarily save the fields under a key combination of trainee ID and language_specialisms" do
        expect(form_store).to receive(:set).with(trainee.id, :language_specialisms, {
          course_subject_one: params[:course_subject_one],
          course_subject_two: params[:course_subject_two],
          course_subject_three: params[:course_subject_three],
        })

        subject.stash
      end
    end
  end
end
