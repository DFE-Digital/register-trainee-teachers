# frozen_string_literal: true

require "rails_helper"

module Schools
  describe EmployingSchoolForm, type: :model do
    let(:trainee) { create(:trainee) }
    let(:form_store) { class_double(FormStore) }
    let(:school_id) { create(:school).id }
    let(:params) { { "employing_school_id" => school_id } }
    let(:school_id_key) { "employing_school_id" }
    let(:not_applicable) { "employing_school_not_applicable" }

    subject { described_class.new(trainee, params: params, store: form_store) }

    before do
      allow(form_store).to receive(:get).and_return(nil)
      subject.valid?
    end

    describe "#stash" do
      it "uses FormStore to temporarily save the fields under a key combination of trainee ID and employing_school" do
        expect(form_store).to receive(:set).with(trainee.id, :employing_school, subject.fields)

        subject.stash
      end
    end

    describe "#save!" do
      before do
        allow(form_store).to receive(:get).and_return({ "employing_school_id" => school_id })
        allow(form_store).to receive(:set).with(trainee.id, :employing_school, nil)
      end

      it "takes any data from the form store and saves it to the database" do
        expect { subject.save! }.to change(trainee, :employing_school_id).to(school_id)
      end
    end

    context "empty form data" do
      let(:params) { { "query" => "w" } }

      it "returns an error" do
        expect(subject.errors[:query]).to include(I18n.t("activemodel.errors.models.schools_form.attributes.query.length", count: 2))
      end
    end

    context "when searching again" do
      let(:params) { { "results_search_again_query" => "a", school_id_key => "results_search_again" } }

      it "returns an error against the search again query" do
        expect(subject.errors[:results_search_again_query]).to include(I18n.t("activemodel.errors.models.schools_form.attributes.query.length", count: 2))
      end
    end

    context "with no school chosen and no query provided" do
      let(:form_name) { school_id_key.sub("id", "form") }
      let(:params) { { "results_search_again_query" => "", school_id_key => "", "search_results_found" => "true" } }

      it "returns an error" do
        expect(subject.errors[school_id_key]).to include(
          I18n.t("activemodel.errors.models.schools/#{form_name}.attributes.#{school_id_key}.blank"),
        )
      end
    end
  end
end
