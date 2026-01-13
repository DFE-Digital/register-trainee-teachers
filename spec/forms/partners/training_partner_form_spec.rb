# frozen_string_literal: true

require "rails_helper"

module Partners
  describe TrainingPartnerForm, type: :model do
    let(:trainee) { create(:trainee) }
    let(:form_store) { class_double(FormStore) }
    let(:training_partner_id) { create(:training_partner, :school).id }
    let(:params) { { "training_partner_id" => training_partner_id } }

    subject { described_class.new(trainee, params: params, store: form_store) }

    before do
      allow(form_store).to receive(:get).and_return(nil)

      subject.valid?
    end

    context "empty form data" do
      let(:params) { { "query" => "w" } }

      it "returns an error" do
        expect(subject.errors[:query]).to include(I18n.t("activemodel.errors.models.training_partner_form.attributes.query.length", count: 2))
      end
    end

    context "when searching again" do
      let(:params) { { "results_search_again_query" => "a", "training_partner_id" => "results_search_again" } }

      it "returns an error against the search again query" do
        expect(subject.errors[:results_search_again_query]).to include(I18n.t("activemodel.errors.models.training_partner_form.attributes.query.length", count: 2))
      end
    end

    context "with no training partner chosen and no query provided" do
      let(:params) { { "results_search_again_query" => "", "training_partner_id" => "", "search_results_found" => "true" } }

      it "returns an error" do
        expect(subject.errors[:training_partner_id]).to include(
          I18n.t("activemodel.errors.models.partners/training_partner_form.attributes.training_partner_id.blank"),
        )
      end
    end

    describe "#stash" do
      it "uses FormStore to temporarily save the fields under a key combination of trainee ID and training_partner" do
        expect(form_store).to receive(:set).with(trainee.id, :training_partner, subject.fields)

        subject.stash
      end
    end

    describe "#save!" do
      before do
        allow(form_store).to receive(:get).and_return({ "training_partner_id" => training_partner_id })
        allow(form_store).to receive(:set).with(trainee.id, :training_partner, nil)
      end

      it "takes any data from the form store and saves it to the database" do
        expect { subject.save! }.to change(trainee, :training_partner_id).to(training_partner_id)
      end
    end
  end
end
