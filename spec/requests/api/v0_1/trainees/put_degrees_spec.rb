# frozen_string_literal: true

require "rails_helper"

describe "`PUT /trainees/:trainee_slug/degrees/:slug` endpoint" do
  context "with a valid authentication token and the feature flag on" do
    let(:accountancy_subject_uuid) { "917f70f0-5dce-e911-a985-000d3ab79618" }
    let(:accounting_subject_uuid) { "937f70f0-5dce-e911-a985-000d3ab79618" }

    let(:provider) { trainee.provider }
    let(:token) { AuthenticationToken.create_with_random_token(provider: provider, name: "test token", created_by: provider.users.first).last }
    let(:auth_token) do
      create(
        :authentication_token,
        hashed_token: AuthenticationToken.hash_token(token),
      )
    end
    let(:trainee) { create(:trainee) }
    let!(:degree) do
      create(
        :degree,
        :uk_degree_with_details,
        trainee: trainee,
        subject_uuid: accountancy_subject_uuid,
        grade: "Third-class honours",
        institution: "Ravensbourne University London",
        uk_degree: "Bachelor of Arts",
        graduation_year: 1978,
      )
    end
    let!(:original_subject) { degree.subject }
    let(:new_subject) { "100105" }

    context "with a valid trainee and degree" do
      context "when using partial HESA attributes" do
        it "updates the degree and returns a 200 status (ok)" do
          put(
            "/api/v0.1/trainees/#{trainee.slug}/degrees/#{degree.slug}",
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: {
              data: { subject: new_subject },
            }.to_json,
          )

          expect(response).to have_http_status(:ok)

          degree_attributes = response.parsed_body[:data]

          expect(degree_attributes[:grade]).to eq("05")
          expect(degree_attributes[:subject]).to eq(new_subject)
          expect(degree_attributes[:institution]).to eq("0030")
          expect(degree_attributes[:graduation_year]).to eq(1978)
          expect(degree_attributes[:country]).to be_nil
          expect(degree_attributes[:locale_code]).to be_nil
          expect(degree_attributes[:uk_degree]).to eq("051")
          expect(degree_attributes[:uk_degree_uuid]).not_to be_nil
          expect(degree_attributes[:institution_uuid]).not_to be_nil
          expect(degree_attributes[:subject_uuid]).not_to be_nil
          expect(degree_attributes[:grade_uuid]).not_to be_nil
          expect(degree_attributes[:degree_id]).not_to be_nil

          degree.reload

          expect(degree.grade).to eq("Third-class honours")
          expect(degree.subject).to eq("Accounting")
          expect(degree.institution).to eq("Ravensbourne University London")
          expect(degree.uk_degree).to eq("Bachelor of Arts")
          expect(degree.graduation_year).to eq(1978)
          expect(degree.country).to be_nil
          expect(degree.locale_code).to eq("uk")
        end
      end

      context "with a non_uk_degree" do
        let(:uk_degree) { "051" }
        let(:non_uk_degree) { "097" }
        let(:country) { "MX" }

        it "updates the degree and returns a 200 status (ok)" do
          put(
            "/api/v0.1/trainees/#{trainee.slug}/degrees/#{degree.slug}",
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: {
              data: { non_uk_degree:, country: },
            }.to_json,
          )

          expect(response).to have_http_status(:ok)

          degree_attributes = response.parsed_body[:data]

          expect(degree_attributes[:grade]).to eq("05")
          expect(degree_attributes[:subject]).to eq("100104")
          expect(degree_attributes[:country]).to eq("MX")
          expect(degree_attributes[:non_uk_degree]).to eq("097")
          expect(degree_attributes[:locale_code]).to be_nil
          expect(degree_attributes[:uk_degree]).to be_nil
          expect(degree_attributes[:uk_degree_uuid]).to be_nil
          expect(degree_attributes[:institution_uuid]).not_to be_nil
          expect(degree_attributes[:subject_uuid]).not_to be_nil
          expect(degree_attributes[:grade_uuid]).not_to be_nil
          expect(degree_attributes[:degree_id]).not_to be_nil

          degree.reload

          expect(degree.locale_code).to eq("non_uk")
          expect(degree.country).to eq("Mexico")
          expect(degree.non_uk_degree).to eq("Bachelor of Education Scotland and Northern Ireland")
          expect(degree.uk_degree).to be_nil
          expect(degree.uk_degree_uuid).to be_nil

          put(
            "/api/v0.1/trainees/#{trainee.slug}/degrees/#{degree.slug}",
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: {
              data: { uk_degree: },
            }.to_json,
          )

          expect(response).to have_http_status(:ok)

          degree_attributes = response.parsed_body["data"]

          expect(degree_attributes[:grade]).to eq("05")
          expect(degree_attributes[:subject]).to eq("100104")
          expect(degree_attributes[:institution]).to eq("0030")
          expect(degree_attributes[:graduation_year]).to eq(1978)
          expect(degree_attributes[:country]).to be_nil
          expect(degree_attributes[:locale_code]).to be_nil
          expect(degree_attributes[:uk_degree]).to eq("051")
          expect(degree_attributes[:uk_degree_uuid]).not_to be_nil
          expect(degree_attributes[:institution_uuid]).not_to be_nil
          expect(degree_attributes[:subject_uuid]).not_to be_nil
          expect(degree_attributes[:grade_uuid]).not_to be_nil
          expect(degree_attributes[:degree_id]).not_to be_nil

          degree.reload

          expect(degree.grade).to eq("Third-class honours")
          expect(degree.subject).to eq("Accountancy")
          expect(degree.institution).to eq("Ravensbourne University London")
          expect(degree.uk_degree).to eq("Bachelor of Arts")
          expect(degree.uk_degree_uuid).not_to be_nil
          expect(degree.graduation_year).to eq(1978)
          expect(degree.country).to be_nil
          expect(degree.locale_code).to eq("uk")
        end
      end

      context "when using multiple HESA attributes" do
        let(:degrees_attributes) do
          {
            grade: "02",
            subject: "100425",
            institution: "0117",
            uk_degree: "083",
            graduation_year: "2015-01-01",
            country: "XF",
          }
        end

        it "updates the degree and returns a 200 status (ok)" do
          put(
            "/api/v0.1/trainees/#{trainee.slug}/degrees/#{degree.slug}",
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: {
              data: degrees_attributes,
            }.to_json,
          )

          expect(response).to have_http_status(:ok)

          degree_attributes = response.parsed_body["data"]

          expect(degree_attributes["grade"]).to eq("02")
          expect(degree_attributes["subject"]).to eq("100425")
          expect(degree_attributes["institution"]).to eq("0117")
          expect(degree_attributes["uk_degree"]).to eq("083")
          expect(degree_attributes["graduation_year"]).to eq(2015)
          expect(degree_attributes["country"]).to be_nil
          expect(degree_attributes["locale_code"]).to be_nil

          degree.reload

          expect(degree.grade).to eq("Upper second-class honours (2:1)")
          expect(degree.subject).to eq("Physics")
          expect(degree.institution).to eq("University of East Anglia")
          expect(degree.uk_degree).to eq("Bachelor of Science")
          expect(degree.graduation_year).to eq(2015)
          expect(degree.country).to be_nil
          expect(degree.locale_code).to eq("uk")
        end
      end
    end

    context "with duplicate degree" do
      let(:uk_degree) { build(:degree, :uk_degree_with_details) }
      let(:non_uk_degree) { build(:degree, :non_uk_degree_with_details) }
      let(:trainee) { create(:trainee, degrees: [uk_degree, non_uk_degree]) }
      let(:degrees_attributes) do
        non_uk_degree.attributes.symbolize_keys.slice(
          :country, :grade, :grade_uuid, :subject, :subject_uuid, :institution, :institution_uuid, :uk_degree, :uk_degree_uuid, :graduation_year, :non_uk_degree
        ).merge(Api::V01::DegreeSerializer.new(non_uk_degree).as_hash.symbolize_keys)
      end

      before do
        degrees_attributes[:graduation_year] = Date.new(degrees_attributes[:graduation_year]).to_s
      end

      it "returns a 409 (conflict) status", openapi: false do
        put(
          "/api/v0.1/trainees/#{trainee.slug}/degrees/#{uk_degree.slug}",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: {
            data: degrees_attributes,
          }.to_json,
        )

        expect(response).to have_http_status(:conflict)
        expect(response.parsed_body["errors"].first).to match(
          { error: "Conflict",
            message: "This is a duplicate degree" },
        )
        expect(response.parsed_body["data"]).to contain_exactly(
          JSON.parse(Api::V01::DegreeSerializer.new(trainee.degrees.non_uk.first).as_hash.to_json),
        )
        expect {
          uk_degree.reload
        }.not_to change(uk_degree, :attributes)
      end
    end

    context "with an invalid trainee" do
      let(:trainee_for_another_provider) { create(:trainee) }

      it "does not update the degree and returns a 404 status (not_found)" do
        put(
          "/api/v0.1/trainees/#{trainee_for_another_provider.slug}/degrees/#{degree.slug}",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: {
            data: { subject: new_subject },
          }.to_json,
        )
        expect(response).to have_http_status(:not_found)
        expect(trainee.reload.degrees.count).to eq(1)
        expect(trainee.reload.degrees.first.subject).to eq(original_subject)
      end
    end

    context "with an invalid degree" do
      let(:degrees_attributes) do
        {
          grade: "First",
          subject: "Practical Magic",
          graduation_year: (Time.zone.now.year + 2).to_s,
        }
      end

      before do
        put(
          "/api/v0.1/trainees/#{trainee.slug}/degrees/#{degree.slug}",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: {
            data:,
          }.to_json,
        )
      end

      context "with a uk_degree" do
        let(:data) do
          degrees_attributes.merge(
            uk_degree: "Bachelor of Arts",
            institution: "University of Oxford",
            country: "France",
          )
        end

        it "does not create a new degree and returns a 422 status (unprocessable_entity) status" do
          expect(response).to have_http_status(:unprocessable_entity)

          expect(response.parsed_body[:errors]).to contain_exactly(
            { "error" => "UnprocessableEntity", "message" => "Subject can't be blank" },
            { "error" => "UnprocessableEntity", "message" => "Uk degree has invalid reference data values" },
            { "error" => "UnprocessableEntity", "message" => "Grade can't be blank" },
          )
        end
      end

      context "with a non_uk_degree" do
        let(:data) do
          degrees_attributes.merge(
            country: "France",
            non_uk_degree: "Bachelor of Arts",
          )
        end

        it "does not create a new degree and returns a 422 status (unprocessable_entity) status" do
          expect(response).to have_http_status(:unprocessable_entity)

          expect(response.parsed_body[:errors]).to contain_exactly(
            { "error" => "UnprocessableEntity", "message" => "Subject can't be blank" },
            { "error" => "UnprocessableEntity", "message" => "Non uk degree has invalid reference data values" },
            { "error" => "UnprocessableEntity", "message" => "Country has invalid reference data values" },
          )
        end
      end
    end

    context "with an invalid request structure" do
      it "does not update the degree and returns a 422 status (unprocessable_entity)" do
        put(
          "/api/v0.1/trainees/#{trainee.slug}/degrees/#{degree.slug}",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: {
            foo: { subject: "new_subject" },
          }.to_json,
        )
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to eq(["Param is missing or the value is empty: data"])
        expect(trainee.reload.degrees.first.subject).to eq(original_subject)
      end
    end
  end
end
