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
        headers: { Authorization: "Bearer #{token}", **json_headers },
        params: { data: { first_names: "Alice" } }.to_json,
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
        headers: { Authorization: "Bearer #{token}", **json_headers },
        params: { data: { first_names: "Alice" } }.to_json,
      )
      expect(response).to have_http_status(:not_found)
      expect(trainee.reload.first_names).to eq("Bob")
    end
  end

  context "with a valid authentication token" do
    let(:token) { AuthenticationToken.create_with_random_token(provider:) }
    let(:slug) { trainee.slug }
    let(:endpoint) { "/api/v0.1/trainees/#{slug}" }
    let(:data) { { first_names: "Alice" } }
    let(:params) { { data: } }

    before do
      create(:nationality, :irish)
      create(:nationality, :french)

      put(
        endpoint,
        headers: { Authorization: "Bearer #{token}", **json_headers },
        params: params.to_json,
      )
    end

    context "when the trainee does not exist" do
      let(:slug) { "missing-trainee-slug" }
      let(:data) { { first_names: "Alice" } }

      it "returns status 404" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when request body is invalid (not a serialised trainee)" do
      let(:params) { { foo: { bar: "Alice" } } }

      it "returns status 422" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body[:errors]).to contain_exactly("Param is missing or the value is empty: data")
      end
    end

    context "when the request data is invalid (has an invalid attribute value)" do
      context "attribute errors supersede" do
        let(:data) { { first_names: "Llanfairpwllgwyngyllgogerychwyrdrobwllllantysiliogogogoch", email: "invalid" } }

        it "returns status 422" do
          expect(response).to have_http_status(:unprocessable_entity)

          expect(response.parsed_body[:errors]).to include("Email Enter an email address in the correct format, like name@example.com")
        end
      end

      context "validator errors" do
        let(:data) { { first_names: "Llanfairpwllgwyngyllgogerychwyrdrobwllllantysiliogogogoch" } }

        it "returns status 422" do
          expect(response).to have_http_status(:unprocessable_entity)

          expect(response.parsed_body[:errors]).to contain_exactly(["personal_details", { "first_names" => ["First name must be 50 characters or fewer"] }])
        end
      end
    end

    context "when the trainee does not belong to the authenticated provider" do
      let(:slug) { other_trainee.slug }
      let(:data) { { first_names: "Alice" } }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when updating with valid params" do
      let(:data) { { first_names: "Alice", provider_trainee_id: "99157234/2/01" } }

      it "returns status 200 with a valid JSON response" do
        expect(response).to have_http_status(:ok)

        expect(trainee.reload.first_names).to eq("Alice")
        expect(trainee.provider_trainee_id).to eq("99157234/2/01")
        expect(response.parsed_body[:data]["trainee_id"]).to eq(trainee.slug)
      end
    end

    context "when updating with valid nationality" do
      let(:data) { { nationality: "IE" } }

      it "returns status 200" do
        expect(response).to have_http_status(:ok)
        expect(trainee.reload.nationalities.first.name).to eq("irish")
      end
    end

    context "when course_age_range is empty" do
      let(:data) { { course_age_range: "" } }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("Course age range can't be blank")
      end
    end

    context "when course_age_range is invalid" do
      let(:data) { { course_age_range: "invalid" } }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("Course age range is not included in the list")
      end
    end

    context "when sex is empty" do
      let(:data) { { sex: "" } }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("Sex can't be blank")
      end
    end

    context "when sex is invalid" do
      let(:data) { { sex: "invalid" } }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("Sex is not included in the list")
      end
    end

    context "when modifying nationality" do
      let(:data) { { nationality: "IE" } }

      it "returns status 200 and updates nationality" do
        expect(response).to have_http_status(:ok)
        expect(trainee.reload.nationalities.map(&:name)).to contain_exactly("irish")
      end

      it "we can update nationality without creating a dual nationality" do
        put(
          "/api/v0.1/trainees/#{trainee.slug}",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: { data: { nationality: "FR" } }.to_json,
        )
        expect(response).to have_http_status(:ok)
        expect(trainee.reload.nationalities.map(&:name)).to contain_exactly("french")
      end

      context "with an invalid HESA nationality code" do
        let(:data) { { nationality: "XX" } }

        it "return status is 422 and the trainee is not updated" do
          put(
            "/api/v0.1/trainees/#{trainee.slug}",
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: { data: { nationality: "XX" } }.to_json,
          )
          expect(response).to have_http_status(:unprocessable_entity)
          expect(trainee.reload.nationalities.map(&:name)).to be_empty
        end
      end
    end

    it "returns status 422 with an invalid `itt_start_date` and the trainee is not updated" do
      original_itt_start_date = trainee.itt_start_date
      put(
        "/api/v0.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { itt_start_date: "2023-02-30" } },
      )
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to have_key("errors")
      expect(response.parsed_body["errors"]).to include("Itt start date is invalid")
      expect(trainee.reload.itt_start_date).to eq(original_itt_start_date)
    end

    it "returns status 422 with an invalid `itt_end_date` and the trainee is not updated" do
      original_itt_end_date = trainee.itt_end_date

      put(
        "/api/v0.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { itt_start_date: "2023-02-28", itt_end_date: "2023-13-13" } },
      )

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to have_key("errors")
      expect(response.parsed_body["errors"]).to include("Itt end date is invalid")
      expect(trainee.reload.itt_end_date).to eq(original_itt_end_date)
    end

    it "returns status 422 with an invalid `itt_start_date/itt_end_date` combination and the trainee is not updated" do
      original_itt_end_date = trainee.itt_end_date
      original_itt_start_date = trainee.itt_start_date

      put(
        "/api/v0.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { hesa_id: nil, itt_start_date: "2023-02-28", itt_end_date: "2022-02-28" } },
      )

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to have_key("errors")
      expect(response.parsed_body[:errors]).to contain_exactly(["course_details", { "itt_end_date" => ["The Expected end date must be after the start date"] }])
      expect(trainee.reload.itt_start_date).to eq(original_itt_start_date)
      expect(trainee.reload.itt_end_date).to eq(original_itt_end_date)
    end

    it "returns status 422 with an invalid `trainee_start_date` and the trainee is not updated" do
      put(
        "/api/v0.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { trainee_start_date: "2023-04-31" } },
      )

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["errors"]).to include("Trainee start date is invalid")
      expect(response.parsed_body).to have_key("errors")
    end

    it "returns status 422 with a future `trainee_start_date` and the trainee is not updated" do
      put(
        "/api/v0.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { trainee_start_date: "#{Time.zone.today.year + 1}-08-01" } },
      )

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to have_key("errors")
    end

    context "when read only attributes are submitted" do
      let(:ethnic_background) { Dttp::CodeSets::Ethnicities::MAPPING.keys.sample }
      let(:ethnic_group) { Diversities::BACKGROUNDS.select { |_key, values| values.include?(ethnic_background) }&.keys&.first }
      let(:trainee) { create(:trainee, :in_progress, :with_hesa_trainee_detail, ethnic_group:, ethnic_background:) }

      before do
        put(
          "/api/v0.1/trainees/#{trainee.slug}",
          headers: { Authorization: "Bearer #{token}" },
          params: params,
          as: :json,
        )
      end

      context "when the ethnicity is provided" do
        let(:params) do
          {
            data: {
              trn: "567899",
              ethnicity: "899",
              ethnic_group: "mixed_ethnic_group",
              ethnic_background: "Another Mixed background",
            },
          }
        end

        it "sets the enthnic attributes based on ethnicity" do
          expect(response).to have_http_status(:ok)

          trainee.reload

          expect(trainee.trn).to be_nil
          expect(trainee.ethnic_group).to eq("other_ethnic_group")
          expect(trainee.ethnic_background).to eq("Another ethnic background")

          parsed_body = response.parsed_body[:data]

          expect(parsed_body[:ethnicity]).to eq("899")
          expect(parsed_body[:trn]).to be_nil
          expect(parsed_body[:ethnic_group]).to eq(trainee.ethnic_group)
          expect(parsed_body[:ethnic_background]).to eq(trainee.ethnic_background)
        end
      end

      context "when the ethnicity is not provided" do
        let(:params) do
          {
            data: {
              trn: "567899",
              ethnic_group: "mixed_ethnic_group",
              ethnic_background: "Another Mixed background",
            },
          }
        end

        it "does not update the ethnic attributes" do
          expect(response).to have_http_status(:ok)

          trainee.reload

          expect(trainee.trn).to be_nil

          expect(trainee.ethnic_group).to eq(ethnic_group)
          expect(trainee.ethnic_background).to eq(ethnic_background)

          parsed_body = response.parsed_body[:data]

          expect(parsed_body[:trn]).to be_nil
          expect(parsed_body[:ethnicity]).to eq(Hesa::CodeSets::Ethnicities::MAPPING.key(ethnic_background))
          expect(parsed_body[:ethnic_group]).to eq(ethnic_group)
          expect(parsed_body[:ethnic_background]).to eq(ethnic_background)
        end
      end
    end
  end

  describe "ethnicity" do
    let(:token) { AuthenticationToken.create_with_random_token(provider:) }

    before do
      put(
        "/api/v0.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: params,
        as: :json,
      )
    end

    context "when present" do
      let(:params) do
        {
          data: {
            ethnicity:,
          },
        }
      end

      let(:ethnicity) { "142" }

      it do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body[:data][:ethnicity]).to eq(ethnicity)
      end
    end

    context "when not present" do
      let(:params) do
        {
          data: {
            first_names: "Alice",
          },
        }
      end

      it do
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body[:data][:ethnicity]).to eq("997")
      end
    end

    context "when invalid" do
      let(:params) do
        {
          data: {
            ethnicity: "1000",
          },
        }
      end

      it do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body[:errors]).to contain_exactly("Ethnicity is not included in the list")
      end
    end
  end

  context "Updating a newly created trainee", feature_register_api: true do
    let(:token) { "trainee_token" }
    let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }
    let!(:nationality) { create(:nationality, :british) }

    let(:headers) { { Authorization: token, **json_headers } }

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
              subject: "100485",
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
        let(:slug) { response.parsed_body[:data][:trainee_id] }
        let(:trainee) { Trainee.last.reload }

        before do
          allow(Api::MapHesaAttributes::V01).to receive(:call).and_call_original
          allow(Trainees::MapFundingFromDttpEntityId).to receive(:call).and_call_original

          post "/api/v0.1/trainees", params: params_for_create.to_json, headers: headers
        end

        it "creates a trainee" do
          expect(response).to have_http_status(:created)
          expect(Trainee.count).to eq(1)

          expect(trainee.state).to eq("submitted_for_trn")
          expect(trainee.slug).to eq(slug)
        end

        context "when updating a newly created trainee with valid params" do
          let(:params_for_update) do
            {
              data:
                {
                  first_names: "Alice",
                  study_mode: "63",
                },
            }
          end

          it "updates the trainee" do
            put(
              "/api/v0.1/trainees/#{slug}",
              params: params_for_update.to_json,
              headers: headers,
            )

            expect(response).to have_http_status(:ok)
            expect(trainee.first_names).to eq("Alice")

            expect(response.parsed_body[:data][:trainee_id]).to eq(slug)
            expect(response.parsed_body[:data][:study_mode]).to eq("63")
          end
        end

        context "when request body is not valid JSON" do
          let(:params_for_update) { "{ \"data\": { \"first_names\": \"Alice\", \"last_name\": \"Roberts\", } }" }

          it "does not update the trainee and returns a meaningful error", openapi: false do
            put(
              "/api/v0.1/trainees/#{slug}",
              headers: headers,
              params: params_for_update,
            )

            expect(response).to have_http_status(:bad_request)
            expect(trainee.reload.first_names).to eq("John")
            expect(response.parsed_body).to have_key(:errors)
          end
        end
      end
    end
  end
end
