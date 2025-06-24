# frozen_string_literal: true

require "rails_helper"

describe "`PUT /api/v2025.0-rc/trainees/:id` endpoint" do
  let(:trainee) do
    create(
      :trainee,
      :in_progress,
      :with_training_route,
      :with_no_funding_hesa_trainee_detail,
      :with_lead_partner,
      :with_employing_school,
      :with_diversity_information,
      first_names: "Bob",
    )
  end
  let(:other_trainee) { create(:trainee, :in_progress, first_names: "Bob") }
  let(:provider) { trainee.provider }
  let!(:academic_cycle) { create(:academic_cycle, :current) }

  context "with an invalid authentication token" do
    let(:token) { "not-a-valid-token" }

    it "returns status code 401 unauthorized" do
      put(
        "/api/v2025.0-rc/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}", **json_headers },
        params: { data: { first_names: "Alice" } }.to_json,
      )
      expect(response).to have_http_status(:unauthorized)
      expect(trainee.reload.first_names).to eq("Bob")
    end
  end

  context "with an valid authentication token and the feature flag off", feature_register_api: false do
    let(:token) { AuthenticationToken.create_with_random_token(provider: provider, name: "test token", created_by: provider.users.first).token }

    it "returns status code 404 not found" do
      put(
        "/api/v2025.0-rc/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}", **json_headers },
        params: { data: { first_names: "Alice" } }.to_json,
      )
      expect(response).to have_http_status(:not_found)
      expect(trainee.reload.first_names).to eq("Bob")
    end
  end

  context "with a valid authentication token" do
    let(:token) { AuthenticationToken.create_with_random_token(provider: provider, name: "test token", created_by: provider.users.first).token }
    let(:slug) { trainee.slug }
    let(:endpoint) { "/api/v2025.0-rc/trainees/#{slug}" }
    let(:data) { { first_names: "Alice" } }
    let(:params) { { data: } }

    before do
      create(:nationality, :irish)
      create(:nationality, :french)
    end

    context "when the trainee does not exist" do
      let(:slug) { "missing-trainee-slug" }
      let(:data) { { first_names: "Alice" } }

      before do
        put(
          endpoint,
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      it "returns status code 404" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when request body has invalid reference data values (not a serialised trainee)" do
      let(:params) { { foo: { bar: "Alice" } } }

      before do
        put(
          endpoint,
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      it "returns status code 422" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body[:errors]).to contain_exactly("Param is missing or the value is empty: data")
      end
    end

    context "when the request data has invalid reference data values (has an invalid attribute value)" do
      before do
        put(
          endpoint,
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      context "attribute errors supersede" do
        let(:data) { { first_names: "Llanfairpwllgwyngyllgogerychwyrdrobwllllantysiliogogogocwhereisthecookie", email: "invalid" } }

        it "returns status code 422" do
          expect(response).to have_http_status(:unprocessable_entity)

          expect(response.parsed_body[:errors]).to include("email Enter an email address in the correct format, like name@example.com")
        end
      end

      context "validator errors" do
        let(:data) { { first_names: "Llanfairpwllgwyngyllgogerychwyrdrobwllllantysiliogogogocwhereisthecookie" } }

        it "returns status code 422" do
          expect(response).to have_http_status(:unprocessable_entity)

          expect(response.parsed_body[:errors]).to contain_exactly(["personal_details", { "first_names" => ["First name must be 60 characters or fewer"] }])
        end
      end
    end

    context "when the trainee does not belong to the authenticated provider" do
      let(:slug) { other_trainee.slug }
      let(:data) { { first_names: "Alice" } }

      before do
        put(
          endpoint,
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      it "returns status code 404" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when updating with valid params" do
      let(:data) { { first_names: "Alice", provider_trainee_id: "99157234/2/01" } }

      before do
        put(
          endpoint,
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      it "returns status code 200 with a valid JSON response" do
        expect(response).to have_http_status(:ok)

        expect(trainee.reload.first_names).to eq("Alice")
        expect(trainee.provider_trainee_id).to eq("99157234/2/01")
        expect(response.parsed_body[:data]["trainee_id"]).to eq(trainee.slug)
      end
    end

    context "when updating a trainee without `hesa_trainee_details` with valid params" do
      let(:data) { { first_names: "Alice", provider_trainee_id: "99157234/2/01", itt_start_date: 1.month.ago.iso8601 } }
      let(:trainee) do
        create(
          :trainee,
          :in_progress,
          :with_training_route,
          :with_lead_partner,
          :with_employing_school,
          :with_diversity_information,
          first_names: "Bob",
          hesa_id: "1234567890",
        )
      end

      before do
        put(
          endpoint,
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      it "returns status code 200 with a valid JSON response" do
        expect(response).to have_http_status(:ok)

        expect(trainee.reload.first_names).to eq("Alice")
        expect(trainee.provider_trainee_id).to eq("99157234/2/01")
        expect(response.parsed_body[:data]["trainee_id"]).to eq(trainee.slug)
      end
    end

    context "when updating with valid nationality" do
      let(:data) { { nationality: "IE" } }

      before do
        put(
          endpoint,
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      it "returns status code 200" do
        expect(response).to have_http_status(:ok)
        expect(trainee.reload.nationalities.first.name).to eq("irish")
      end
    end

    context "when updating with valid course_age_range" do
      let(:data) { { course_age_range: } }

      let(:course_age_range) { "13909" }

      before do
        put(
          endpoint,
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      it "returns status code 200" do
        course_min_age, course_max_age = DfE::ReferenceData::AgeRanges::HESA_CODE_SETS[course_age_range]

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body[:data][:course_min_age]).to eq(course_min_age)
        expect(response.parsed_body[:data][:course_max_age]).to eq(course_max_age)
      end
    end

    context "when course_age_range is empty" do
      let(:data) { { course_age_range: "" } }

      before do
        put(
          endpoint,
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("course_age_range can't be blank")
      end
    end

    context "when course_age_range has invalid reference data values" do
      let(:data) { { course_age_range: "1234" } }

      before do
        put(
          endpoint,
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly(
          "course_age_range has invalid reference data value of '1234'. Valid values are '13909', '13911', '13912', '13913', '13914', '13915', '13916', '13917', '13918', '13919'.",
        )
      end
    end

    context "when sex is empty" do
      let(:data) { { sex: "" } }

      before do
        put(
          endpoint,
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("sex can't be blank")
      end
    end

    context "when sex has invalid reference data values" do
      let(:data) { { sex: "3" } }

      before do
        put(
          endpoint,
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly(
          "sex has invalid reference data value of '3'. Valid values are '10', '11', '12', '96', '99'.",
        )
      end
    end

    context "when modifying nationality" do
      let(:data) { { nationality: "IE" } }

      before do
        put(
          endpoint,
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      it "returns status code 200 and updates nationality" do
        expect(response).to have_http_status(:ok)
        expect(trainee.reload.nationalities.map(&:name)).to contain_exactly("irish")
      end

      it "we can update nationality without creating a dual nationality" do
        put(
          "/api/v2025.0-rc/trainees/#{trainee.slug}",
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
            "/api/v2025.0-rc/trainees/#{trainee.slug}",
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: { data: { nationality: "XX" } }.to_json,
          )
          expect(response).to have_http_status(:unprocessable_entity)
          expect(trainee.reload.nationalities.map(&:name)).to be_empty
        end
      end
    end

    it "returns status code 422 with an invalid `itt_start_date` and the trainee is not updated" do
      original_itt_start_date = trainee.itt_start_date
      put(
        "/api/v2025.0-rc/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { itt_start_date: "2023-02-30" } },
      )
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to have_key("errors")
      expect(response.parsed_body["errors"]).to include("itt_start_date is invalid")
      expect(trainee.reload.itt_start_date).to eq(original_itt_start_date)
    end

    it "returns status code 422 with an invalid `itt_end_date` and the trainee is not updated" do
      original_itt_end_date = trainee.itt_end_date

      put(
        "/api/v2025.0-rc/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { itt_start_date: "2023-02-28", itt_end_date: "2023-13-13" } },
      )

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to have_key("errors")
      expect(response.parsed_body["errors"]).to include("itt_end_date is invalid")
      expect(trainee.reload.itt_end_date).to eq(original_itt_end_date)
    end

    it "returns status code 422 with an invalid `itt_start_date/itt_end_date` combination and the trainee is not updated" do
      original_itt_end_date = trainee.itt_end_date
      original_itt_start_date = trainee.itt_start_date

      put(
        "/api/v2025.0-rc/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { hesa_id: nil, itt_start_date: "2023-02-28", itt_end_date: "2022-02-28" } },
      )

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to have_key("errors")
      expect(response.parsed_body[:errors]).to contain_exactly("itt_end_date must be after itt_start_date")
      expect(trainee.reload.itt_start_date).to eq(original_itt_start_date)
      expect(trainee.reload.itt_end_date).to eq(original_itt_end_date)
    end

    it "returns status code 422 with an invalid `trainee_start_date` and the trainee is not updated" do
      put(
        "/api/v2025.0-rc/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { trainee_start_date: "2023-04-31" } },
      )

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["errors"]).to include("trainee_start_date is invalid")
      expect(response.parsed_body).to have_key("errors")
    end

    it "returns status code 422 with a future `trainee_start_date` and the trainee is not updated" do
      put(
        "/api/v2025.0-rc/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
        params: { data: { trainee_start_date: "#{Time.zone.today.year + 1}-08-01" } },
      )

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to have_key("errors")
    end

    context "with lead_partner_and_employing_school_attributes" do
      before do
        put(
          endpoint,
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      context "when lead_partner_urn is blank and employing_school_urn is not applicable" do
        let(:params) do
          {
            data: data.merge(
              lead_partner_urn: "",
              employing_school_urn: "900020",
            ),
          }
        end

        it "sets the lead_partner_urn to nil and employing_school_urn to nil" do
          expect(response.parsed_body[:data][:lead_partner_urn]).to be_nil
          expect(response.parsed_body[:data][:employing_school_urn]).to be_nil
        end

        it "sets the lead_partner_not_applicable and employing_school_not_applicable to true" do
          trainee.reload

          expect(trainee.lead_partner_not_applicable).to be(true)
          expect(trainee.employing_school_not_applicable).to be(true)
        end

        context "with existing lead_partner_not_applicable and employing_school_not_applicable set to true" do
          let(:trainee) do
            create(
              :trainee,
              :in_progress,
              :with_training_route,
              :with_no_funding_hesa_trainee_detail,
              lead_partner_not_applicable: true,
              employing_school_not_applicable: true,
            )
          end

          it "does not change lead_partner_urn and employing_school_urn" do
            expect(response.parsed_body[:data][:lead_partner_urn]).to be_nil
            expect(response.parsed_body[:data][:employing_school_urn]).to be_nil
          end

          it "does not change lead_partner_not_applicable and employing_school_not_applicable" do
            trainee.reload

            expect(trainee.lead_partner_not_applicable).to be(true)
            expect(trainee.employing_school_not_applicable).to be(true)
          end
        end
      end

      context "when lead_partner_urn is present" do
        context "when lead_partner_urn is not an applicable school urn" do
          let(:params) do
            {
              data: data.merge(
                lead_partner_urn: "900020",
                employing_school_urn: "",
              ),
            }
          end

          it "sets lead_partner_urn to nil and employing_school_urn to nil" do
            expect(response.parsed_body[:data][:lead_partner_urn]).to be_nil
            expect(response.parsed_body[:data][:employing_school_urn]).to be_nil
          end

          it "sets lead_partner_not_applicable to true and employing_school_not_applicable to true" do
            trainee.reload

            expect(trainee.lead_partner_not_applicable).to be(true)
            expect(trainee.employing_school_not_applicable).to be(true)
          end
        end

        context "when lead_partner_urn is a new urn" do
          let(:params) do
            {
              data: data.merge(
                lead_partner_urn: new_lead_partner.urn,
                employing_school_urn: "",
              ),
            }
          end

          context "when lead_partner exists" do
            let(:new_lead_partner) { create(:lead_partner, :school) }

            it "sets lead_partner_urn to lead_partner#urn and employing_school_urn to nil" do
              expect(response.parsed_body[:data][:lead_partner_urn]).to eq(new_lead_partner.urn)
              expect(response.parsed_body[:data][:employing_school_urn]).to be_nil
            end

            it "sets lead_partner_not_applicable to false and employing_school_not_applicable to true" do
              trainee.reload

              expect(trainee.lead_partner_not_applicable).to be(false)
              expect(trainee.employing_school_not_applicable).to be(true)
            end
          end

          context "when lead_partner does not exist" do
            let(:new_lead_partner) { build(:lead_partner, :school) }

            it "sets lead_partner_urn to nil and lead_partner_not_applicable to true" do
              expect(response.parsed_body[:data][:lead_partner_urn]).to be_nil

              trainee.reload

              expect(trainee.lead_partner_not_applicable).to be(true)
            end
          end
        end

        context "when employing_school_urn is not an applicable school urn" do
          let(:params) do
            {
              data: data.merge(
                lead_partner_urn: "900020",
                employing_school_urn: "900030",
              ),
            }
          end

          it "sets lead_partner_urn to nil and employing_school_urn to nil" do
            expect(response.parsed_body[:data][:lead_partner_urn]).to be_nil
            expect(response.parsed_body[:data][:employing_school_urn]).to be_nil
          end

          it "sets lead_partner_not_applicable and employing_school_not_applicable to true" do
            trainee.reload

            expect(trainee.lead_partner_not_applicable).to be(true)
            expect(trainee.employing_school_not_applicable).to be(true)
          end
        end

        context "when employing_school_urn is an applicable school urn" do
          let(:params) do
            {
              data: data.merge(
                lead_partner_urn: "900020",
                employing_school_urn: new_employing_school.urn,
              ),
            }
          end

          context "when employing_school exists" do
            let(:new_employing_school) { create(:school) }

            it "sets lead_partner_urn to nil and employing_school_urn to employing_school#urn" do
              expect(response.parsed_body[:data][:lead_partner_urn]).to be_nil
              expect(response.parsed_body[:data][:employing_school_urn]).to eq(new_employing_school.urn)
            end

            it "sets lead_partner_not_applicable to true and employing_school_not_applicable to false" do
              trainee.reload

              expect(trainee.lead_partner_not_applicable).to be(true)
              expect(trainee.employing_school_not_applicable).to be(false)
            end
          end

          context "when employing_school does not exist" do
            let(:new_employing_school) { build(:school) }

            it "sets lead_partner_urn and employing_school_urn to nil" do
              expect(response.parsed_body[:data][:lead_partner_urn]).to be_nil
              expect(response.parsed_body[:data][:employing_school_urn]).to be_nil
            end

            it "sets lead_partner_not_applicable and employing_school_not_applicable to true" do
              trainee.reload

              expect(trainee.lead_partner_not_applicable).to be(true)
              expect(trainee.employing_school_not_applicable).to be(true)
            end
          end
        end
      end
    end

    context "when read only attributes are submitted", openapi: false do
      let(:ethnic_background) { Hesa::CodeSets::Ethnicities::MAPPING.values.uniq.sample }
      let(:ethnic_group) { Diversities::BACKGROUNDS.select { |_key, values| values.include?(ethnic_background) }&.keys&.first }
      let(:trainee) do
        create(
          :trainee,
          :in_progress,
          :with_lead_partner,
          :with_employing_school,
          :with_training_route,
          :with_no_funding_hesa_trainee_detail,
          :with_diversity_information,
          ethnic_group:,
          ethnic_background:,
        )
      end

      before do
        put(
          "/api/v2025.0-rc/trainees/#{trainee.slug}",
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

        it "sets the ethnic attributes based on ethnicity" do
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

    describe "with ethnicity" do
      let(:trainee) do
        create(
          :trainee,
          :in_progress,
          :with_lead_partner,
          :with_employing_school,
          :with_training_route,
          :with_no_funding_hesa_trainee_detail,
          :with_diversity_information,
          ethnic_group:,
          ethnic_background:,
        )
      end
      let(:ethnic_background) { Hesa::CodeSets::Ethnicities::MAPPING.values.uniq.sample }
      let(:ethnic_group) { Diversities::BACKGROUNDS.select { |_key, values| values.include?(ethnic_background) }&.keys&.first }

      before do
        put(
          endpoint,
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
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

      context "when nil" do
        let(:params) do
          {
            data: {
              ethnicity: nil,
            },
          }
        end

        it do
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body[:data][:ethnicity]).to eq("997")
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
          expect(response.parsed_body[:data][:ethnicity]).to eq(Hesa::CodeSets::Ethnicities::MAPPING.key(ethnic_background))
        end
      end

      context "when invalid" do
        let(:params) do
          {
            data: {
              ethnicity: "Irish",
            },
          }
        end

        it do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body[:errors]).to include(
            /ethnicity has invalid reference data value of 'Irish'./,
          )
        end
      end
    end

    describe "with training_route" do
      context "when present" do
        let(:params) do
          {
            data: {
              itt_start_date:,
              training_route:,
            },
          }
        end

        let(:itt_start_date) { "2023-01-01" }
        let(:training_route) { Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_undergrad]] }

        before do
          put(
            endpoint,
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )
        end

        it do
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body[:data][:training_route]).to eq(training_route)
        end
      end

      context "when not present" do
        let(:params) do
          {
            data: {
              training_route:,
            },
          }
        end

        let(:training_route) { nil }

        before do
          put(
            endpoint,
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )
        end

        it do
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body[:data][:training_route]).to eq(
            Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_postgrad]],
          )
          expect(trainee.reload.training_route).to eq(TRAINING_ROUTE_ENUMS[:provider_led_postgrad])
        end
      end

      context "when invalid" do
        let(:params) do
          {
            data: {
              itt_start_date:,
              itt_end_date:,
              training_route:,
            },
          }
        end

        let(:itt_start_date) { "2021-08-01" }
        let(:itt_end_date)   { "2022-01-01" }
        let(:training_route) { Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_postgrad]] }

        let!(:academic_cycle) { create(:academic_cycle, cycle_year: 2021, next_cycle: true) }

        before do
          put(
            endpoint,
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )
        end

        it do
          expect(response.parsed_body[:errors]).to contain_exactly(
            "training_route has invalid reference data value of 'provider_led_postgrad'. Valid values are '02', '03', '09', '10', '11', '12', '14'.",
          )
        end
      end
    end

    describe "with disabilities" do
      before do
        create(:disability, :deaf)
        create(:disability, :blind)
        put(
          endpoint,
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
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
          expect(response.parsed_body[:data][:disability_disclosure]).to eq("disabled")
          expect(response.parsed_body[:data][:disability1]).to eq("55")
          expect(response.parsed_body[:data][:disability2]).to be_nil

          expect(trainee.reload.disabilities.count).to eq(1)
          expect(trainee.reload.disabilities.map(&:name)).to contain_exactly("Mental health condition")
        end
      end

      context "when disability1 is set" do
        let(:params) do
          {
            data: {
              disability1: "57",
            },
          }
        end

        it do
          expect(response).to have_http_status(:ok)

          expect(response.parsed_body[:data][:disability_disclosure]).to eq("disabled")
          expect(response.parsed_body[:data][:disability1]).to eq("57")
          expect(response.parsed_body[:data][:disability2]).to be_nil

          expect(trainee.disabilities.count).to eq(1)
          expect(trainee.disabilities.map(&:name)).to contain_exactly("Deaf")
        end
      end

      context "when disability2 is set" do
        let(:params) do
          {
            data: {
              disability2: "57",
            },
          }
        end

        it do
          expect(response).to have_http_status(:ok)

          expect(response.parsed_body[:data][:disability_disclosure]).to eq("disabled")
          expect(response.parsed_body[:data][:disability1]).to eq("55")
          expect(response.parsed_body[:data][:disability2]).to eq("57")

          expect(trainee.disabilities.count).to eq(2)
          expect(trainee.disabilities.map(&:name)).to contain_exactly("Mental health condition", "Deaf")
        end
      end

      context "when disability1 & disability2 are set" do
        let(:params) do
          {
            data: {
              disability1: "58",
              disability2: "57",
            },
          }
        end

        it do
          expect(response).to have_http_status(:ok)

          expect(response.parsed_body[:data][:disability_disclosure]).to eq("disabled")
          expect(response.parsed_body[:data][:disability1]).to eq("58")
          expect(response.parsed_body[:data][:disability2]).to eq("57")

          expect(trainee.disabilities.count).to eq(2)
          expect(trainee.disabilities.map(&:name)).to contain_exactly("Blind", "Deaf")
        end
      end

      context "when disability1 & disability2 have the same code values" do
        let(:params) do
          {
            data: {
              disability1: "58",
              disability2: "58",
            },
          }
        end

        it do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body[:errors]).to contain_exactly(
            "disabilities contain duplicate values",
          )
        end
      end

      %w[95 98 99].each do |code|
        let(:disability_disclosures) {
          {
            "95" => "no_disability",
            "98" => "disability_not_provided",
            "99" => "disability_not_provided",
          }
        }

        context "when disability1 has code #{code}" do
          let(:params) do
            {
              data: {
                disability1: code,
              },
            }
          end

          it do
            expect(response).to have_http_status(:success)

            expect(response.parsed_body[:data][:disability_disclosure]).to eq(disability_disclosures[code])
            expect(response.parsed_body[:data][:disability1]).to eq(code)

            trainee.reload

            expect(trainee.disability_disclosure).to eq(disability_disclosures[code])
            expect(trainee.disabilities).to be_empty
          end
        end
      end
    end

    context "with course subjects" do
      let(:token) { AuthenticationToken.create_with_random_token(provider: provider, name: "test token", created_by: provider.users.first).token }

      context "when HasCourseAttributes#primary_education_phase? is true" do
        before do
          put(
            endpoint,
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )
        end

        context "when '100511' is not present" do
          let(:course_age_range) { "13914" }
          let(:params) do
            {
              data: {
                course_subject_one: "100346",
                course_subject_two: "101410",
                course_subject_three: "100366",
                course_age_range: course_age_range,
              },
            }
          end

          it "sets the correct subjects" do
            trainee.reload

            expect(trainee.course_age_range).to eq(DfE::ReferenceData::AgeRanges::HESA_CODE_SETS[course_age_range])
            expect(trainee.course_subject_one).to eq("primary teaching")
            expect(trainee.course_subject_two).to eq("biology")
            expect(trainee.course_subject_three).to eq("historical linguistics")

            expect(response.parsed_body[:data][:course_subject_one]).to eq("100511")
            expect(response.parsed_body[:data][:course_subject_two]).to eq("100346")
            expect(response.parsed_body[:data][:course_subject_three]).to eq("101410")
          end
        end

        context "when '100511' is present" do
          let(:params) do
            {
              data: {
                course_subject_one: "100511",
                course_subject_two: "101410",
                course_subject_three: "100366",
              },
            }
          end

          it "sets the correct subjects" do
            trainee.reload

            expect(trainee.course_subject_one).to eq("primary teaching")
            expect(trainee.course_subject_two).to eq("historical linguistics")
            expect(trainee.course_subject_three).to eq("computer science")

            expect(response.parsed_body[:data][:course_subject_one]).to eq("100511")
            expect(response.parsed_body[:data][:course_subject_two]).to eq("101410")
            expect(response.parsed_body[:data][:course_subject_three]).to eq("100366")
          end
        end
      end

      context "when HasCourseAttributes#primary_education_phase? is false" do
        let(:params) do
          {
            data: {
              course_subject_one: "100346",
              course_subject_two: "101410",
              course_subject_three: "100366",
            },
          }
        end

        before do
          put(
            endpoint,
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )
        end

        it "sets the correct subjects" do
          trainee.reload

          expect(trainee.course_subject_one).to eq("biology")
          expect(trainee.course_subject_two).to eq("historical linguistics")
          expect(trainee.course_subject_three).to eq("computer science")

          expect(response.parsed_body[:data][:course_subject_one]).to eq("100346")
          expect(response.parsed_body[:data][:course_subject_two]).to eq("101410")
          expect(response.parsed_body[:data][:course_subject_three]).to eq("100366")
        end
      end

      context "when course_subject_one has invalid reference data values" do
        let(:course_subject_one) { "chemistry" }
        let(:params) do
          { data: { course_subject_one: } }
        end

        before do
          put(
            endpoint,
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )
        end

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            /course_subject_one has invalid reference data value of 'chemistry'/,
          )
        end
      end

      context "when course_subject_two has invalid reference data values" do
        let(:course_subject_two) { "child development" }
        let(:params) do
          { data: { course_subject_two: } }
        end

        before do
          put(
            endpoint,
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )
        end

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            /course_subject_two has invalid reference data value of/,
          )
        end
      end

      context "when course_subject_three has invalid reference data values" do
        let(:course_subject_three) { "classical studies" }
        let(:params) do
          { data: { course_subject_three: } }
        end

        before do
          put(
            endpoint,
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )
        end

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            /course_subject_three has invalid reference data value of/,
          )
        end
      end

      context "when study_mode has invalid reference data values" do
        let(:study_mode) { 1 }
        let(:params) do
          { data: { study_mode: } }
        end

        before do
          put(
            endpoint,
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )
        end

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            /study_mode has invalid reference data value of/,
          )
        end
      end

      context "when nationality has invalid reference data values" do
        let(:nationality) { "british" }
        let(:params) do
          { data: { nationality: } }
        end

        before do
          put(
            endpoint,
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )
        end

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            /nationality has invalid reference data value of/,
          )
        end
      end

      context "when training_initiative has invalid reference data values" do
        let(:training_initiative) { "now_teach" }
        let(:params) do
          { data: { training_initiative: } }
        end

        before do
          put(
            endpoint,
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )
        end

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to contain_exactly(
            /training_initiative has invalid reference data value of/,
          )
        end
      end

      context "when funding_method has invalid reference data values" do
        let(:funding_method) { "8c629dd7-bfc3-eb11-bacc-000d3addca7a" }
        let(:params) do
          { data: { funding_method: } }
        end

        before do
          put(
            endpoint,
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )
        end

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            /funding_method has invalid reference data value of/,
          )
        end
      end

      context "when itt_aim has invalid reference data values" do
        let(:itt_aim) { "321" }
        let(:params) do
          { data: { itt_aim: } }
        end

        before do
          put(
            endpoint,
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )
        end

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            /itt_aim has invalid reference data value of/,
          )
        end
      end

      context "when itt_qualification_aim has invalid reference data values" do
        let(:itt_qualification_aim) { "321" }
        let(:params) do
          { data: { itt_qualification_aim: } }
        end

        before do
          put(
            endpoint,
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )
        end

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            "itt_qualification_aim has invalid reference data value of '321'. Valid values are '001', '002', '003', '004', '007', '008', '020', '021', '028', '031', '032'.",
          )
        end
      end
    end
  end

  context "Updating a newly created trainee" do
    let(:token) { "trainee_token" }
    let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }
    let!(:nationality) { create(:nationality, :british) }

    let(:headers) { { Authorization: token, **json_headers } }

    let(:start_academic_cycle) { create(:academic_cycle, :current) }
    let(:end_academic_cycle) { create(:academic_cycle, next_cycle: true) }

    let(:fund_code) { Hesa::CodeSets::FundCodes::NOT_ELIGIBLE }
    let(:funding_method) { Hesa::CodeSets::BursaryLevels::NONE }

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
              grade: "02",
              subject: "100425",
              institution: "0116",
              uk_degree: "083",
              graduation_year: "2003-06-01",
            },
          ],
          placements_attributes: [
            {
              urn: "900020",
            },
          ],
          itt_aim: "202",
          itt_qualification_aim: "001",
          course_year: "2012",
          course_age_range: "13915",
          fund_code: fund_code,
          funding_method: funding_method,
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
          let!(:funding_rule) {
            funding_rule = create(:funding_method, :bursary, amount: 9000, training_route: TRAINING_ROUTE_ENUMS[:provider_led_undergrad])
            create(:funding_method_subject, funding_method: funding_rule, allocation_subject: course_allocation_subject)
          }
        end

        let(:course_subject) { cs }
        let(:slug) { response.parsed_body[:data][:trainee_id] }
        let(:trainee) { Trainee.last.reload }

        before do
          allow(Api::V20250Rc::HesaMapper::Attributes).to receive(:call).and_call_original
          allow(Trainees::MapFundingFromDttpEntityId).to receive(:call).and_call_original

          post "/api/v2025.0-rc/trainees", params: params_for_create.to_json, headers: headers
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
              "/api/v2025.0-rc/trainees/#{slug}",
              params: params_for_update.to_json,
              headers: headers,
            )

            expect(response).to have_http_status(:ok)
            expect(trainee.first_names).to eq("Alice")

            expect(response.parsed_body[:data][:trainee_id]).to eq(slug)
            expect(response.parsed_body[:data][:study_mode]).to eq("63")
          end
        end

        context "when degrees_attributes are present in the params" do
          let(:params_for_update) do
            {
              data: {
                degrees_attributes: [
                  {
                    grade: "02",
                    subject: "100485",
                    non_uk_degree: "097",
                    country: "MX",
                    graduation_year: "2003",
                  },
                ],
              },
            }
          end

          it "does not update the degrees" do
            put(
              "/api/v2025.0-rc/trainees/#{slug}",
              params: params_for_update.to_json,
              headers: headers,
            )

            expect(response).to have_http_status(:ok)

            trainee.reload

            expect(trainee.degrees.count).to be(1)

            degree = trainee.degrees.take

            expect(degree.locale_code).to eq("uk")
            expect(degree.subject).to eq("Physics")
            expect(degree.institution).to eq("Durham University")
            expect(degree.graduation_year).to eq(2003)
            expect(degree.grade).to eq("Upper second-class honours (2:1)")
            expect(degree.uk_degree).to eq("Bachelor of Science")
            expect(degree.country).to be_nil
          end
        end

        context "when request body is not valid JSON" do
          let(:params_for_update) { "{ \"data\": { \"first_names\": \"Alice\", \"last_name\": \"Roberts\", } }" }

          it "does not update the trainee and returns a meaningful error", openapi: false do
            put(
              "/api/v2025.0-rc/trainees/#{slug}",
              headers: headers,
              params: params_for_update,
            )
            expect(response).to have_http_status(:bad_request)
            expect(trainee.reload.first_names).to eq("John")
            expect(response.parsed_body).to have_key(:errors)
          end
        end

        context "with a fund_code is ineligible for funding" do
          let(:params_for_update) do
            {
              data: {
                training_route: Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:opt_in_undergrad]],
                fund_code: Hesa::CodeSets::FundCodes::NOT_ELIGIBLE,
                funding_method: Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY,
              },
            }
          end

          before do
            put("/api/v2025.0-rc/trainees/#{slug}", params: params_for_update.to_json, headers: headers)
          end

          it "return status code 422 with a meaningful error message" do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.parsed_body["message"]).to eq(
              "Validation failed: 1 error prohibited this trainee from being saved",
            )
            expect(response.parsed_body["errors"]).to contain_exactly(
              "funding_method training route ‘opt_in_undergrad’ and subject code ‘primary teaching’ are not eligible for ‘bursary’ in academic cycle ‘#{academic_cycle.label}’",
            )
          end
        end
      end
    end
  end
end
