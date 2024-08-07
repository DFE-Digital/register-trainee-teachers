# frozen_string_literal: true

shared_examples "school form validations" do |school_id_key|
  before { subject.valid? }

  let(:not_applicable) do
    if school_id_key == "lead_school_id"
      "lead_partner_not_applicable"
    else
      school_id_key.sub("id", "not_applicable")
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

  context "school chosen but also marked as not applicable" do
    let(:form_name) { school_id_key.sub("id", "form") }
    let(:params) { { school_id_key => "1", not_applicable => "1", query: "school" } }

    it "returns an error" do
      expect(subject.errors[:query]).to include(
        I18n.t("activemodel.errors.models.schools/#{form_name}.attributes.query.both_fields_are_present"),
      )
    end
  end

  context "school not chosen, but query present and also marked as not applicable" do
    let(:form_name) { school_id_key.sub("id", "form") }
    let(:params) { { not_applicable => "1", query: "school" } }

    it "returns an error" do
      expect(subject.errors[:query]).to include(
        I18n.t("activemodel.errors.models.schools/#{form_name}.attributes.query.both_fields_are_present"),
      )
    end
  end
end
