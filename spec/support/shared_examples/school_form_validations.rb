# frozen_string_literal: true

RSpec.shared_examples "school form validations" do |school_id_key|
  before { subject.valid? }

  context "empty form data" do
    let(:params) { { "query" => "w" } }

    it "returns an error" do
      expect(subject.errors[:query]).to include(I18n.t("activemodel.errors.models.schools_form.attributes.query.length", count: 2))
    end
  end

  context "when searching again" do
    let(:params) { { "results_search_again_query" => "a" } }

    it "returns an error against the search again query" do
      expect(subject.errors[:results_search_again_query]).to include(I18n.t("activemodel.errors.models.schools_form.attributes.query.length", count: 2))
    end
  end

  context "with no school chosen and no query provided" do
    let(:params) { { "results_search_again_query" => "", school_id_key => "" } }

    it "returns an error" do
      expect(subject.errors[school_id_key]).to include(I18n.t("activemodel.errors.models.schools/employing_school_form.attributes.employing_school_id.blank"))
    end
  end
end
