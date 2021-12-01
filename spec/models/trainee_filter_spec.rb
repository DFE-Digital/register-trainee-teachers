# frozen_string_literal: true

require "rails_helper"

describe TraineeFilter do
  let(:permitted_params) do
    ActionController::Parameters.new(params)
    .permit(:provider, :subject, :text_search, training_route: [], state: [], record_source: [], study_mode: [])
  end

  subject { TraineeFilter.new(params: permitted_params) }

  returns_nil = "returns nil"

  shared_examples returns_nil do
    it returns_nil do
      expect(subject.filters).to be_nil
    end
  end

  describe "#filters" do
    context "with fully valid parameters" do
      let(:params) do
        {
          subject: "Biology",
          text_search: "search terms",
          training_route: [TRAINING_ROUTE_ENUMS[:assessment_only]],
          state: %w[draft],
        }
      end

      it "returns the correct filter hash" do
        expect(subject.filters).to eq(permitted_params.to_h)
      end
    end

    context "with provider" do
      let(:provider) { create(:provider) }
      let(:params) { { provider: provider.id } }

      it "returns the provider from the DB" do
        expect(subject.filters).to eq({ "provider" => provider })
      end
    end

    context "with lowercase subject" do
      let(:subject_filter) { "japanese" }
      let(:params) { { subject: subject_filter } }

      it "applies the capitalized subject as stored in the DB" do
        expect(subject.filters).to eq({ "subject" => subject_filter.capitalize })
      end
    end

    context "with 'All subjects'" do
      let(:params) { { subject: "All subjects" } }

      include_examples returns_nil
    end

    context "with invalid record_source" do
      let(:params) { { record_source: %w[hackerman] } }

      include_examples returns_nil
    end

    context "with invalid training route" do
      let(:params) { { training_route: %w[not_a_training_route] } }

      include_examples returns_nil
    end

    context "with invalid state" do
      let(:params) { { state: %w[not_a_state] } }

      include_examples returns_nil
    end

    context "with invalid provider id" do
      let(:params) { { provider: "not an id" } }

      include_examples returns_nil
    end

    context "with empty params" do
      let(:params) { {} }

      include_examples returns_nil
    end

    context "with trainee start year" do
      let(:params) { { trainee_start_year: ["2020"] } }

      subject { TraineeFilter.new(params: params) }

      it "returns trainee_start_year in hash" do
        expect(subject.filters).to eq({ "trainee_start_year" => ["2020"] })
      end
    end
  end
end
