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
      let(:params) { { language_specialisms: [] } }

      before do
        subject.valid?
      end

      it "returns an error" do
        expect(subject.errors[:language_specialisms]).to include(
          I18n.t(
            "activemodel.errors.models.language_specialisms_form.attributes.language_specialisms.blank",
          ),
        )
      end
    end

    context "when more than three subjects are supplied" do
      let(:params) { { language_specialisms: %w[french german spanish mandarin] } }

      before do
        subject.valid?
      end

      it "returns an error" do
        expect(subject.errors[:language_specialisms]).to include(
          I18n.t(
            "activemodel.errors.models.language_specialisms_form.attributes.language_specialisms.invalid",
          ),
        )
      end
    end
  end

  context "valid trainee" do
    let(:params) { { language_specialisms: %w[french german spanish] } }

    let(:trainee) { create(:trainee) }

    describe "#stash" do
      let(:fields) { params }

      it "uses FormStore to temporarily save the fields under a key combination of trainee ID and language_specialisms" do
        expect(form_store).to receive(:set).with(trainee.id, :language_specialisms, {
          course_subject_one: params[:language_specialisms][0],
          course_subject_three: params[:language_specialisms][2],
          course_subject_two: params[:language_specialisms][1],
        })

        subject.stash
      end
    end
  end
end
