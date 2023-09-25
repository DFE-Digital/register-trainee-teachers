# frozen_string_literal: true

require "rails_helper"

module Funding
  describe GrantAndTieredBursaryForm, type: :model do
    let(:params) { {} }
    let(:trainee) { create(:trainee, :with_grant_and_tiered_bursary) }

    let(:form_store) { FormStore }

    subject { described_class.new(trainee, params: params, store: form_store) }

    describe "validations" do
      let(:inclusion_values) do
        Trainee.bursary_tiers.keys + ["none"]
      end

      it { is_expected.to validate_inclusion_of(:custom_bursary_tier).in_array(inclusion_values) }
    end

    describe "#stash" do
      before do
        allow(form_store).to receive(:get).and_return(nil)
      end

      subject { described_class.new(trainee, params: params, store: form_store) }

      let(:form_store) { class_double(FormStore) }

      it "uses FormStore to temporarily save the fields under a key combination of trainee ID and grant_and_tiered_bursary" do
        expect(form_store).to receive(:set).with(trainee.id, :grant_and_tiered_bursary, subject.fields)

        subject.stash
      end
    end

    describe "#save!" do
      let(:custom_bursary_tier) { "none" }
      let(:applying_for_grant) { "false" }

      let(:params) { { custom_bursary_tier:, applying_for_grant: } }

      it "sets applying_for_bursary to false" do
        expect { subject.save! }.to change(trainee.reload, :applying_for_bursary).from(true).to(false)
      end

      it "sets applying_for_grant to false" do
        expect { subject.save! }.to change(trainee.reload, :applying_for_grant).from(true).to(false)
      end

      it "sets bursary_tier to nil" do
        expect { subject.save! }.to change(trainee.reload, :bursary_tier).from("tier_one").to(nil)
      end

      it "sets applying_for_scholarship to nil" do
        expect { subject.save! }.to change(trainee.reload, :applying_for_scholarship).to(false)
      end
    end
  end
end
