# frozen_string_literal: true

require "rails_helper"

module Schools
  describe LeadSchoolForm, type: :model do
    let(:trainee) { create(:trainee) }
    let(:form_store) { class_double(FormStore) }
    let(:lead_school_id) { create(:school, lead_school: true).id }
    let(:params) { { "lead_school_id" => lead_school_id } }

    subject { described_class.new(trainee, params: params, store: form_store) }

    before do
      allow(form_store).to receive(:get).and_return(nil)
    end

    describe "validations" do
      before { subject.valid? }

      context "when query length is too short" do
        let(:params) { { "query" => "a" } }

        it "returns an error" do
          expect(subject.errors[:query]).to include(I18n.t("activemodel.errors.models.schools_form.attributes.query.length", count: 2))
        end
      end

      context "when searching again" do
        let(:params) { { "results_search_again_query" => "a" } }

        it "returns an error against the search again query" do
          expect(subject.errors[:results_search_again_query]).to include(I18n.t("activemodel.errors.models.schools_form.attributes.query.length", count: 2))
        end

        context "with no lead school chosen and no query provided" do
          let(:params) { { "results_search_again_query" => "", "lead_school_id" => "" } }

          it "returns an error" do
            expect(subject.errors[:lead_school_id]).to include(I18n.t("activemodel.errors.models.schools/lead_school_form.attributes.lead_school_id.blank"))
          end
        end
      end
    end

    describe "#stash" do
      it "uses FormStore to temporarily save the fields under a key combination of trainee ID and lead_school" do
        expect(form_store).to receive(:set).with(trainee.id, :lead_school, subject.fields)

        subject.stash
      end
    end

    describe "#save!" do
      before do
        allow(form_store).to receive(:get).and_return({ "lead_school_id" => lead_school_id })
        allow(form_store).to receive(:set).with(trainee.id, :lead_school, nil)
      end

      it "takes any data from the form store and saves it to the database" do
        expect { subject.save! }.to change(trainee, :lead_school_id).to(lead_school_id)
      end
    end
  end
end
