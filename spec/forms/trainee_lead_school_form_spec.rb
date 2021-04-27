# frozen_string_literal: true

require "rails_helper"

describe TraineeLeadSchoolForm, type: :model do
  let(:trainee) { create(:trainee) }
  let(:form_store) { class_double(FormStore) }
  let(:lead_school_id) { create(:school, lead_school: true).id }
  let(:params) { { "lead_school_id" => lead_school_id } }

  subject { described_class.new(trainee, params: params, store: form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:lead_school_id) }

    context "empty form data" do
      let(:params) { { "lead_school_id" => "" } }

      before { subject.valid? }

      it "returns an error" do
        expect(subject.errors[:lead_school_id]).to include(I18n.t("activemodel.errors.models.trainee_lead_school_form.attributes.lead_school_id.blank"))
      end
    end
  end

  describe "#stash" do
    it "uses FormStore to temporarily save the fields under a key combination of trainee ID and trainee_lead_school" do
      expect(form_store).to receive(:set).with(trainee.id, :trainee_lead_school, subject.fields)

      subject.stash
    end
  end

  describe "#save!" do
    before do
      allow(form_store).to receive(:get).and_return({ "lead_school_id" => lead_school_id })
      allow(form_store).to receive(:set).with(trainee.id, :trainee_lead_school, nil)
    end

    it "takes any data from the form store and saves it to the database" do
      expect { subject.save! }.to change(trainee, :lead_school_id).to(lead_school_id)
    end
  end
end
