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

    describe "#save!" do
      before do
        allow(form_store).to receive(:set).with(trainee.id, :language_specialisms, nil)
      end

      it "changes related trainee attributes" do
        expect { subject.save! }
          .to change { trainee.course_subject_one }
          .from(nil).to("french")
          .and change { trainee.course_subject_two }
          .from(nil).to("german")
          .and change { trainee.course_subject_three }
          .from(nil).to("spanish")
      end
    end

    describe "#stash" do
      let(:fields) { params }

      it "uses FormStore to temporarily save the fields under a key combination of trainee ID and language_specialisms" do
        expect(form_store).to receive(:set).with(trainee.id, :language_specialisms, fields)

        subject.stash
      end
    end
  end
end
