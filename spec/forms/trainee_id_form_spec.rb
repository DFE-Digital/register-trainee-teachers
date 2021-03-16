# frozen_string_literal: true

require "rails_helper"

describe TraineeIdForm, type: :model do
  let(:params) { {} }
  let(:trainee) { build(:trainee, :not_started) }
  let(:form_store) { class_double(FormStore) }

  subject { described_class.new(trainee, params, form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:trainee_id) }

    context "empty form data" do
      let(:params) { { "trainee_id" => "" } }

      before { subject.valid? }

      it "returns an error" do
        expect(subject.errors[:trainee_id]).to include(I18n.t("activemodel.errors.models.training_details_form.attributes.trainee_id.blank"))
      end
    end
  end

  describe "#stash" do
    let(:trainee) { create(:trainee) }

    it "uses FormStore to temporarily save the fields under a key combination of trainee ID and trainee_id" do
      expect(form_store).to receive(:set).with(trainee.id, :trainee_id, subject.fields)

      subject.stash
    end
  end

  describe "#save!" do
    let(:params) { {} }
    let(:trainee) { create(:trainee) }
    let(:trainee_id) { "123" }

    before do
      allow(form_store).to receive(:get).and_return({ "trainee_id" => trainee_id })
      allow(form_store).to receive(:set).with(trainee.id, :trainee_id, nil)
    end

    it "takes any data from the form store and saves it to the database" do
      expect { subject.save! }.to change(trainee, :trainee_id).to(trainee_id)
    end
  end
end
