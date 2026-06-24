# frozen_string_literal: true

RSpec.shared_examples "a reference data endpoint" do |version|
  let(:reference_data_klass) do
    "Hesa::ReferenceData::#{Api::GetVersionedItem.module_name(version)}".constantize
  end

  describe "GET /api/#{version}/reference-data" do
    context "without authentication" do
      before do
        get "/api/#{version}/reference-data"
      end

      it "returns status code 200" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the register_api feature flag is off", feature_register_api: false do
      before do
        get "/api/#{version}/reference-data"
      end

      it "returns status code 404" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "without a field parameter" do
      before do
        get "/api/#{version}/reference-data"
      end

      it "returns all reference data fields" do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.keys).to match_array(reference_data_klass.available_fields.map(&:to_s))
      end

      it "includes withdrawal reasons" do
        withdrawal_reasons = response.parsed_body.fetch("withdrawal_reasons")

        expect(withdrawal_reasons.fetch("metadata")).to include(
          "name" => "withdrawal_reasons",
          "display_name" => "Withdrawal reasons",
        )
        expect(withdrawal_reasons.fetch("triggers")).to match_array(%w[provider trainee])
        expect(withdrawal_reasons.fetch("future_interest")).to match_array(%w[yes no unknown])
      end

      it "includes structured withdrawal reason entries" do
        entries = response.parsed_body.dig("withdrawal_reasons", "entries")

        expect(entries).to include(
          hash_including(
            "slug" => "record_added_in_error",
            "trigger" => "provider",
            "requires_another_reason" => false,
            "requires_safeguarding_concern_reasons" => false,
          ),
          hash_including(
            "slug" => "trainee_chose_to_withdraw_another_reason",
            "trigger" => "trainee",
            "requires_another_reason" => true,
            "requires_safeguarding_concern_reasons" => false,
          ),
          hash_including(
            "slug" => "safeguarding_concerns",
            "trigger" => "provider",
            "requires_another_reason" => false,
            "requires_safeguarding_concern_reasons" => true,
          ),
        )
      end
    end

    context "with a valid field parameter" do
      before do
        get "/api/#{version}/reference-data", params: { field: field_name }
      end

      let(:field_name) { reference_data_klass.available_fields.first }

      it "returns the unwrapped field payload" do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include("metadata", "entries")
        expect(response.parsed_body.fetch("metadata")).to include("name" => field_name.to_s)
      end
    end

    context "with an unknown field parameter" do
      before do
        get "/api/#{version}/reference-data", params: { field: "bogus" }
      end

      it "returns status code 404" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to eq(
          "errors" => [{ "error" => "NotFound", "message" => "Reference data field 'bogus' not found" }],
        )
      end
    end
  end
end
