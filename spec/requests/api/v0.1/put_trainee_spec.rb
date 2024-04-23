# frozen_string_literal: true

require "rails_helper"

describe "`PUT /api/v0.1/trainees/:id` endpoint" do
  let(:trainee) { create(:trainee, :in_progress, :with_hesa_trainee_detail, first_names: "Bob") }
  let(:other_trainee) { create(:trainee, :in_progress, first_names: "Bob") }
  let(:provider) { trainee.provider }

  context "with an invalid authentication token" do
    let(:token) { "not-a-valid-token" }

    it "returns status 401 unauthorized" do
      put(
        "/api/v0.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { first_names: "Alice" } },
      )
      expect(response).to have_http_status(:unauthorized)
      expect(trainee.reload.first_names).to eq("Bob")
    end
  end

  context "with an valid authentication token and the feature flag off", feature_register_api: false do
    let(:token) { AuthenticationToken.create_with_random_token(provider:) }

    it "returns status 404 not found" do
      put(
        "/api/v0.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { first_names: "Alice" } },
      )
      expect(response).to have_http_status(:not_found)
      expect(trainee.reload.first_names).to eq("Bob")
    end
  end

  context "with a valid authentication token" do
    let(:token) { AuthenticationToken.create_with_random_token(provider:) }

    it "returns status 404 if the trainee does not exist" do
      put(
        "/api/v0.1/trainees/missing-trainee-slug",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { first_names: "Alice" } },
      )
      expect(response).to have_http_status(:not_found)
    end

    it "returns status 422 if the request body is invalid (not a serialised trainee)" do
      put(
        "/api/v0.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { foo: { bar: "Alice" } },
      )
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body[:errors]).to contain_exactly("Param is missing or the value is empty: data")
    end

    it "returns status 422 if the request data is invalid (has an invalid attribute value)" do
      put(
        "/api/v0.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { first_names: "Llanfairpwllgwyngyllgogerychwyrdrobwllllantysiliogogogoch", email: "invalid" } },
      )
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body[:errors]).to contain_exactly(
        ["contact_details", { "email" => ["Enter an email address in the correct format, like name@example.com"] }],
        ["personal_details", { "first_names" => ["First name must be 50 characters or fewer"] }],
      )
    end

    it "returns 404 if the trainee does not belong to the authenticated provider" do
      put(
        "/api/v0.1/trainees/#{other_trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { first_names: "Alice" } },
      )
      expect(response).to have_http_status(:not_found)
    end

    it "returns status 200 with a valid JSON response" do
      put(
        "/api/v0.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { first_names: "Alice", provider_trainee_id: "99157234/2/01" } },
      )
      expect(response).to have_http_status(:ok)
      expect(trainee.reload.first_names).to eq("Alice")
      expect(trainee.provider_trainee_id).to eq("99157234/2/01")
      expect(response.parsed_body[:data]["trainee_id"]).to eq(trainee.slug)
    end

    it "returns status 200 and updates nationality" do
      create(:nationality, :irish)
      put(
        "/api/v0.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { nationality: "IE" } },
      )
      expect(response).to have_http_status(:ok)
      expect(trainee.reload.nationalities.first.name).to eq("irish")
    end
  end

  context "Updating a newly created trainee", feature_register_api: true do
    let(:token) { "trainee_token" }
    let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }
    let!(:nationality) { create(:nationality, :british) }

    let(:headers) { { Authorization: token } }

    let(:start_academic_cycle) { create(:academic_cycle, :current) }
    let(:end_academic_cycle) { create(:academic_cycle, next_cycle: true) }

    let(:params_for_create) do
      {
        data: {
          first_names: "John",
          last_name: "Doe",
          date_of_birth: "1990-01-01",
          sex: Hesa::CodeSets::Sexes::MAPPING.invert[Trainee.sexes[:male]],
          email: "john.doe@example.com",
          nationality: "GB",
          training_route: Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_undergrad]],
          itt_start_date: start_academic_cycle.start_date,
          itt_end_date: end_academic_cycle.end_date,
          course_subject_one: Hesa::CodeSets::CourseSubjects::MAPPING.invert[course_subject],
          study_mode: Hesa::CodeSets::StudyModes::MAPPING.invert[TRAINEE_STUDY_MODE_ENUMS["full_time"]],
          degrees_attributes: [
            {
              subject: "Law",
              institution: nil,
              graduation_date: "2003-06-01",
              subject_one: "100485",
              grade: "02",
              country: "XF",
            },
          ],
          placements_attributes: [
            {
              urn: "900020",
            },
          ],
          itt_aim: 202,
          itt_qualification_aim: "001",
          course_year: "2012",
          course_age_range: "13915",
          fund_code: "7",
          funding_method: "4",
          hesa_id: "0310261553101",
        },
      }
    end

    let(:course_allocation_subject) do
      subject_specialism = create(:subject_specialism, name: course_subject)

      subject_specialism.allocation_subject
    end

    [CourseSubjects::PHYSICS, CourseSubjects::BIOLOGY].each do |cs|
      context "when creating a new trainee with #{cs} course with valid params" do
        if cs == CourseSubjects::PHYSICS
          let!(:funding_method) {
            funding_method = create(:funding_method, :bursary, amount: 9000, training_route: TRAINING_ROUTE_ENUMS[:provider_led_undergrad])
            create(:funding_method_subject, funding_method: funding_method, allocation_subject: course_allocation_subject)
          }
        end

        let(:course_subject) { cs }
        let(:slug) { response.parsed_body["trainee_id"] }
        let(:trainee) { Trainee.last.reload }

        before do
          allow(Api::MapHesaAttributes::V01).to receive(:call).and_call_original
          allow(Trainees::MapFundingFromDttpEntityId).to receive(:call).and_call_original

          post "/api/v0.1/trainees", params: params_for_create, headers: headers
        end

        it "creates a trainee" do
          expect(response).to have_http_status(:created)
          expect(Trainee.count).to eq(1)

          expect(trainee.state).to eq("submitted_for_trn")
          expect(trainee.slug).to eq(slug)
        end

        context "when updating a newly created trainee with valid params" do
          let(:params_for_update) { { data: { first_names: "Alice" } } }

          it "updates the trainee" do
            put(
              "/api/v0.1/trainees/#{slug}",
              params: params_for_update,
              headers: headers,
            )

            expect(response).to have_http_status(:ok)
            expect(trainee.first_names).to eq("Alice")
            expect(response.parsed_body[:data]["trainee_id"]).to eq(slug)
          end
        end

        context "when request body is not valid JSON" do
          let(:params_for_update) { "{ \"data\": { \"first_names\": \"Alice\", \"last_name\": \"Roberts\", } }" }

          it "does not update the trainee and returns a meaningful error" do
            put(
              "/api/v0.1/trainees/#{slug}",
              headers: headers.merge("Content-Type" => "application/json"),
              params: params_for_update,
            )

            expect(response).to have_http_status(:bad_request)
            expect(trainee.reload.first_names).to eq("John")
            expect(response.parsed_body).to have_key("errors")
          end
        end
      end
    end
  end
end
