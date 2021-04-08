# frozen_string_literal: true

require "rails_helper"

module Diversities
  describe DisclosureForm, type: :model do
    let(:params) { {} }
    let(:trainee) { create(:trainee, :diversity_disclosed) }
    let(:form_store) { class_double(FormStore) }

    subject { described_class.new(trainee, params: params, store: form_store) }

    before do
      allow(form_store).to receive(:get).and_return(nil)
    end

    describe "validations" do
      it { is_expected.to validate_presence_of(:diversity_disclosure) }
      it { is_expected.to validate_inclusion_of(:diversity_disclosure).in_array(Diversities::DIVERSITY_DISCLOSURE_ENUMS.values) }
    end

    describe "#stash" do
      it "uses FormStore to temporarily save the fields under a key combination of trainee ID and diversity_disclosure" do
        expect(form_store).to receive(:set).with(trainee.id, :diversity_disclosure, subject.fields)

        subject.stash
      end
    end

    describe "#save!" do
      let(:diversity_not_disclosed) { Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed] }

      before do
        allow(form_store).to receive(:get).and_return({ "diversity_disclosure" => diversity_not_disclosed })
        allow(form_store).to receive(:set).with(trainee.id, :diversity_disclosure, nil)
      end

      it "takes any data from the form store and saves it to the database" do
        expect { subject.save! }.to change(trainee, :diversity_disclosure).to(diversity_not_disclosed)
      end
    end
  end
end
