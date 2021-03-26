# frozen_string_literal: true

require "rails_helper"

module Diversities
  describe DisabilityDisclosureForm, type: :model do
    let(:params) { {} }
    let(:trainee) { create(:trainee, :diversity_disclosed) }
    let(:form_store) { class_double(FormStore) }

    subject { described_class.new(trainee, params, form_store) }

    before do
      allow(form_store).to receive(:get).and_return(nil)
    end

    describe "validations" do
      it { is_expected.to validate_presence_of(:disability_disclosure) }

      it do
        is_expected.to validate_inclusion_of(:disability_disclosure).in_array(
          Diversities::DISABILITY_DISCLOSURE_ENUMS.values,
        )
      end
    end

    describe "#stash" do
      it "uses FormStore to temporarily save the fields under a key combination of trainee ID and disability_disclosure" do
        expect(form_store).to receive(:set).with(trainee.id, :disability_disclosure, subject.fields)

        subject.stash
      end
    end

    describe "#save!" do
      let(:trainee) { create(:trainee, :not_started, :diversity_disclosed) }
      let(:disability_not_provided) { Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] }

      before do
        allow(form_store).to receive(:get).and_return({ "disability_disclosure" => disability_not_provided })
        allow(form_store).to receive(:set).with(trainee.id, :disability_disclosure, nil)
      end

      it "takes any data from the form store and saves it to the database" do
        expect { subject.save! }.to change(trainee, :disability_disclosure).to(disability_not_provided)
      end
    end
  end
end
