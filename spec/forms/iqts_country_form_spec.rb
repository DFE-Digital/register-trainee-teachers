# frozen_string_literal: true

require "rails_helper"

describe IqtsCountryForm, type: :model do
  let(:params) { {} }
  let(:trainee) { build(:trainee) }
  let(:form_store) { class_double(FormStore) }

  subject { described_class.new(trainee, params: params, store: form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:iqts_country) }
  end

  context "with valid params" do
    let(:params) { { iqts_country: "france" } }
    let(:trainee) { create(:trainee, :iqts) }

    describe "#stash" do
      let(:fields) { params }

      it "uses FormStore to temporarily save the fields under a key combination of trainee ID and iqts_country" do
        expect(form_store).to receive(:set).with(trainee.id, :iqts_country, subject.fields)

        subject.stash
      end

      it "doesn't update the trainee's iqts_country" do
        allow(form_store).to receive(:set)

        expect { subject.stash }.not_to change { trainee.iqts_country }
      end
    end

    describe "#save!" do
      let(:iqts_country) { "france" }

      before do
        allow(form_store).to receive(:get).and_return({ "iqts_country" => iqts_country })
        allow(form_store).to receive(:set).with(trainee.id, :iqts_country, nil)
      end

      it "takes data from the form store and saves it to the database" do
        expect { subject.save! }.to change(trainee, :iqts_country).to(iqts_country)
      end
    end
  end
end
