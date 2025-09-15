# frozen_string_literal: true

require "rails_helper"

module Partners
  describe LeadPartnerForm, type: :model do
    let(:trainee) { create(:trainee) }
    let(:form_store) { class_double(FormStore) }
    let(:lead_partner_id) { create(:lead_partner, :school).id }
    let(:params) { { "lead_partner_id" => lead_partner_id } }

    subject { described_class.new(trainee, params: params, store: form_store) }

    before do
      allow(form_store).to receive(:get).and_return(nil)

      subject.valid?
    end

    context "empty form data" do
      let(:params) { { "query" => "w" } }

      it "returns an error" do
        expect(subject.errors[:query]).to include(I18n.t("activemodel.errors.models.lead_partners_form.attributes.query.length", count: 2))
      end
    end

    context "when searching again" do
      let(:params) { { "results_search_again_query" => "a", "lead_partner_id" => "results_search_again" } }

      it "returns an error against the search again query" do
        expect(subject.errors[:results_search_again_query]).to include(I18n.t("activemodel.errors.models.lead_partners_form.attributes.query.length", count: 2))
      end
    end

    context "with no training partner chosen and no query provided" do
      let(:params) { { "results_search_again_query" => "", "lead_partner_id" => "", "search_results_found" => "true" } }

      it "returns an error" do
        expect(subject.errors[:lead_partner_id]).to include(
          I18n.t("activemodel.errors.models.partners/lead_partner_form.attributes.lead_partner_id.blank"),
        )
      end
    end

    describe "#stash" do
      it "uses FormStore to temporarily save the fields under a key combination of trainee ID and lead_partner" do
        expect(form_store).to receive(:set).with(trainee.id, :lead_partner, subject.fields)

        subject.stash
      end
    end

    describe "#save!" do
      before do
        allow(form_store).to receive(:get).and_return({ "lead_partner_id" => lead_partner_id })
        allow(form_store).to receive(:set).with(trainee.id, :lead_partner, nil)
      end

      it "takes any data from the form store and saves it to the database" do
        expect { subject.save! }.to change(trainee, :lead_partner_id).to(lead_partner_id)
      end
    end
  end
end
