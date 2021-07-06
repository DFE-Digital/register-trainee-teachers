# frozen_string_literal: true

require "rails_helper"

module Funding
  describe BursaryForm, type: :model do
    let(:params) { {} }
    let(:trainee) { create(:trainee, applying_for_bursary: true) }
    let(:form_store) { class_double(FormStore) }

    subject { described_class.new(trainee, params: params, store: form_store) }

    before do
      allow(form_store).to receive(:get).and_return(nil)
    end

    describe "validations" do
      it { is_expected.to validate_inclusion_of(:applying_for_bursary).in_array([true, false]) }
      it { is_expected.to validate_inclusion_of(:bursary_tier).in_array(Trainee.bursary_tiers.keys) }

      context "when bursary_tier is set" do
        let(:params) do
          {
            "bursary_tier" => "tier_one",
            "applying_for_bursary" => "false",
          }
        end

        before do
          subject.valid?
        end

        it "sets applying_for_bursary to true" do
          expect(subject.applying_for_bursary).to eq(true)
        end
      end
    end

    describe "#stash" do
      it "uses FormStore to temporarily save the fields under a key combination of trainee ID and bursary" do
        expect(form_store).to receive(:set).with(trainee.id, :bursary, subject.fields)

        subject.stash
      end
    end

    describe "#save!" do
      let(:applying_for_bursary) { false }

      before do
        allow(form_store).to receive(:get).and_return({ "applying_for_bursary" => applying_for_bursary })
        allow(form_store).to receive(:set).with(trainee.id, :bursary, nil)
      end

      it "takes any data from the form store and saves it to the database" do
        expect { subject.save! }.to change(trainee.reload, :applying_for_bursary).to(false)
      end
    end
  end
end
