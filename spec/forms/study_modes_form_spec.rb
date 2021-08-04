# frozen_string_literal: true

require "rails_helper"

describe StudyModesForm, type: :model, feature_course_study_mode: true do
  let(:params) { {} }
  let(:trainee) { build(:trainee) }
  let(:form_store) { class_double(FormStore) }

  subject { described_class.new(trainee, params: params, store: form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
  end

  context "study_mode" do
    context "required route" do
      before do
        subject.valid?
      end

      context "study_mode is blank" do
        let(:trainee) { create(:trainee, :provider_led_postgrad, study_mode: nil) }

        it "returns an error" do
          expect(subject.errors[:study_mode]).not_to be_empty
        end
      end
    end
  end

  context "not required route" do
    let(:trainee) { create(:trainee, :early_years_undergrad) }

    before do
      subject.valid?
    end

    context "study_mode is blank" do
      it "returns no error" do
        expect(subject.errors[:study_mode]).to be_empty
      end
    end
  end
end
