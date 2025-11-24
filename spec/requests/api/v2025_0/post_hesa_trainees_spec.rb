# frozen_string_literal: true

require "rails_helper"

describe "`POST /api/v2025.0/trainees` endpoint" do
  let!(:auth_token) { create(:authentication_token) }
  let!(:token) { auth_token.token }

  let!(:course_allocation_subject) do
    create(:subject_specialism, name: CourseSubjects::BIOLOGY).allocation_subject
  end

  let!(:french_allocation_subject) do
    create(
      :subject_specialism,
      name: CourseSubjects::FRENCH_LANGUAGE,
      allocation_subject: create(:allocation_subject, name: CourseSubjects::FRENCH_LANGUAGE),
    ).allocation_subject
  end

  let(:params) { { data: } }

  let(:graduation_year) { "2003" }
  let(:course_age_range) { "13918" }
  let(:sex) { Hesa::CodeSets::Sexes::MAPPING.keys.sample }
  let(:trainee_start_date) { itt_start_date }
  let(:itt_start_date) { academic_cycle.start_date.iso8601 }
  let(:itt_end_date) { (academic_cycle.start_date + 1.year).iso8601 }
  let(:training_route) { Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_undergrad]] }
  let(:disability1) { "58" }
  let(:disability2) { "57" }
  let(:fund_code) { Hesa::CodeSets::FundCodes::NOT_ELIGIBLE }
  let(:degrees_attributes) {
    [
      {
        grade: "02",
        subject: "100485",
        institution: "0117",
        uk_degree: "083",
        graduation_year: graduation_year,
      },
    ]
  }
  let(:course_subject_one) { Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::BIOLOGY] }

  let(:endpoint) { "/api/v2025.0/trainees" }
  let!(:academic_cycle) { create(:academic_cycle, :current) }

  let(:data) do
    {
      first_names: "John",
      last_name: "Doe",
      previous_last_name: "Smith",
      date_of_birth: "1990-01-01",
      sex: sex,
      email: "john.doe@example.com",
      nationality: "GB",
      training_route: training_route,
      itt_start_date: itt_start_date,
      itt_end_date: itt_end_date,
      trainee_start_date: trainee_start_date,
      course_subject_one: course_subject_one,
      study_mode: ReferenceData::TRAINEE_STUDY_MODES.find("full_time").hesa_codes.first,
      disability1: disability1,
      disability2: disability2,
      degrees_attributes: degrees_attributes,
      placements_attributes: [
        {
          name: "Placement",
          urn: "900020",
        },
      ],
      itt_aim: "202",
      itt_qualification_aim: "001",
      course_year: "2012",
      course_age_range: course_age_range,
      fund_code: fund_code,
      funding_method: Hesa::CodeSets::BursaryLevels::NONE,
      hesa_id: "0310261553101",
      provider_trainee_id: "99157234/2/01",
      pg_apprenticeship_start_date: "2024-03-11",
    }
  end

  before do
    create(:nationality, :british)
    create(:disability, :blind)
    create(:disability, :deaf)
  end

  context "when the trainee_start_date is blank" do
    let(:trainee_start_date) { "" }

    before do
      allow(Api::V20250::HesaMapper::Attributes).to receive(:call).and_call_original
      allow(Trainees::MapFundingFromDttpEntityId).to receive(:call).and_call_original
    end

    it "creates a trainee" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response.parsed_body[:data][:first_names]).to eq("John")
      expect(response.parsed_body[:data][:last_name]).to eq("Doe")
      expect(response.parsed_body[:data][:trainee_start_date]).to eq(itt_start_date)
    end

    context "with enhanced errors" do
      let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

      it "creates a trainee" do
        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

        expect(response.parsed_body[:data][:first_names]).to eq("John")
        expect(response.parsed_body[:data][:last_name]).to eq("Doe")
        expect(response.parsed_body[:data][:trainee_start_date]).to eq(itt_start_date)
      end
    end
  end

  context "when the request is valid" do
    before do
      allow(Api::V20250::HesaMapper::Attributes).to receive(:call).and_call_original
      allow(Trainees::MapFundingFromDttpEntityId).to receive(:call).and_call_original
    end

    it "creates a trainee" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response.parsed_body[:data][:first_names]).to eq("John")
      expect(response.parsed_body[:data][:last_name]).to eq("Doe")
      expect(response.parsed_body[:data][:previous_last_name]).to eq("Smith")
      expect(response.parsed_body[:data][:pg_apprenticeship_start_date]).to eq("2024-03-11")
    end

    context "with enhanced errors" do
      let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

      it "creates a trainee" do
        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

        expect(response.parsed_body[:data][:first_names]).to eq("John")
        expect(response.parsed_body[:data][:last_name]).to eq("Doe")
        expect(response.parsed_body[:data][:previous_last_name]).to eq("Smith")
        expect(response.parsed_body[:data][:pg_apprenticeship_start_date]).to eq("2024-03-11")
      end
    end

    it "sets the correct state" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(Trainee.last.state).to eq("submitted_for_trn")
    end

    it "sets the correct course_min_age and course_max_age" do
      course_min_age, course_max_age = DfE::ReferenceData::AgeRanges::HESA_CODE_SETS[course_age_range]

      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response.parsed_body[:data][:course_min_age]).to eq(course_min_age)
      expect(response.parsed_body[:data][:course_max_age]).to eq(course_max_age)
    end

    it "sets the correct study_mode" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response.parsed_body[:data][:study_mode]).to eq("63")
    end

    it "sets the correct nationality" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response.parsed_body[:data][:nationality]).to eq("GB")
      trainee = Trainee.last
      expect(trainee.nationalities.pluck(:name)).to contain_exactly("british")
    end

    it "sets the correct disabilities" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      parsed_body = response.parsed_body[:data]

      expect(parsed_body[:disability_disclosure]).to eq("disabled")
      expect(parsed_body[:disability1]).to eq("58")
      expect(parsed_body[:disability2]).to eq("57")

      trainee_id = parsed_body[:trainee_id]
      trainee = Trainee.find_by(slug: trainee_id)
      expect(trainee.disabilities.count).to eq(2)
      expect(trainee.disabilities.map(&:name)).to contain_exactly("Blind", "Deaf")
    end

    it "sets the correct funding attributes" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      parsed_body = response.parsed_body[:data]

      expect(Trainees::MapFundingFromDttpEntityId).to have_received(:call).once
      expect(Trainee.last.applying_for_scholarship).to be(false)
      expect(Trainee.last.applying_for_bursary).to be(false)
      expect(Trainee.last.applying_for_grant).to be(false)
      expect(parsed_body[:fund_code]).to eq(Hesa::CodeSets::FundCodes::NOT_ELIGIBLE)
      expect(parsed_body[:funding_method]).to eq(Hesa::CodeSets::BursaryLevels::NONE)
      expect(parsed_body[:applying_for_scholarship]).to be_nil
      expect(parsed_body[:applying_for_bursary]).to be_nil
      expect(parsed_body[:applying_for_grant]).to be_nil
    end

    it "sets the correct lead partner and employing school attributes" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      trainee = Trainee.last

      expect(trainee.lead_partner_not_applicable).to be(true)
      expect(trainee.lead_partner_id).to be_nil
      expect(trainee.employing_school_not_applicable).to be(true)
      expect(trainee.employing_school_id).to be_nil
    end

    it "creates the degrees if provided in the request body" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      degree_attributes = response.parsed_body[:data][:degrees]&.first

      expect(degree_attributes[:subject]).to eq("100485")
      expect(degree_attributes[:institution]).to eq("0117")
      expect(degree_attributes[:graduation_year]).to eq(2003)
      expect(degree_attributes[:subject]).to eq("100485")
      expect(degree_attributes[:grade]).to eq("02")
      expect(degree_attributes[:uk_degree]).to eq("083")
      expect(degree_attributes[:country]).to be_nil

      degree = Degree.last

      expect(degree.locale_code).to eq("uk")
      expect(degree.subject).to eq("Law")
      expect(degree.institution).to eq("University of East Anglia")
      expect(degree.graduation_year).to eq(2003)
      expect(degree.grade).to eq("Upper second-class honours (2:1)")
      expect(degree.uk_degree).to eq("Bachelor of Science")
      expect(degree.country).to be_nil
    end

    context "with a non UK degree" do
      context "when valid" do
        let(:degrees_attributes) do
          [
            {
              grade: "02",
              subject: "100485",
              non_uk_degree: "083",
              graduation_year: graduation_year,
              country: "MX",
            },
          ]
        end

        it "creates the degrees if provided in the request body" do
          post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

          degree_attributes = response.parsed_body[:data][:degrees]&.first

          expect(degree_attributes[:subject]).to eq("100485")
          expect(degree_attributes[:institution]).to be_nil
          expect(degree_attributes[:graduation_year]).to eq(2003)
          expect(degree_attributes[:subject]).to eq("100485")
          expect(degree_attributes[:grade]).to eq("02")
          expect(degree_attributes[:non_uk_degree]).to eq("083")
          expect(degree_attributes[:country]).to eq("MX")

          degree = Degree.last

          expect(degree.locale_code).to eq("non_uk")
          expect(degree.subject).to eq("Law")
          expect(degree.institution).to be_nil
          expect(degree.graduation_year).to eq(2003)
          expect(degree.grade).to eq("Upper second-class honours (2:1)")
          expect(degree.non_uk_degree).to eq("Bachelor of Science")
          expect(degree.country).to eq("Mexico")
        end
      end

      context "when invalid" do
        let(:degrees_attributes) do
          [
            {
              country: "MX",
            },
          ]
        end

        it "returns errors" do
          expect {
            post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
          }.not_to change {
            Degree.count
          }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body[:errors]).to contain_exactly(
            "non_uk_degree must be entered if specifying a previous non-UK degree",
            "subject must be entered if specifying a previous UK degree or non-UK degree",
            "graduation_year must be entered if specifying a previous UK degree or non-UK degree",
          )
        end

        context "with enhanced errors" do
          it "returns errors" do
            expect {
              post endpoint, params: params.to_json, headers: {
                Authorization: token, **json_headers.merge("HTTP_ENHANCED_ERRORS" => "true")
              }
            }.not_to change {
              Degree.count
            }

            expect(response).to have_http_status(:unprocessable_entity)

            expect(response.parsed_body[:errors]).to eq(
              "non_uk_degree" => ["must be entered if specifying a previous non-UK degree"],
              "subject" => ["must be entered if specifying a previous UK degree or non-UK degree"],
              "graduation_year" => ["must be entered if specifying a previous UK degree or non-UK degree"],
            )
          end
        end
      end
    end

    context "with provider_trainee_id" do
      let(:params) do
        {
          data: data.merge(
            provider_trainee_id:,
          ),
        }
      end

      before do
        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
      end

      context "when valid" do
        let(:provider_trainee_id) { Faker::Number.number(digits: 50).to_s }

        it "sets the correct provider_trainee_id" do
          expect(response).to have_http_status(:created)
          expect(response.parsed_body[:data][:provider_trainee_id]).to eq(provider_trainee_id)

          expect(Trainee.last.provider_trainee_id).to eq(provider_trainee_id)
        end
      end

      context "when invalid" do
        let(:provider_trainee_id) { Faker::Number.number(digits: 51).to_s }

        it "returns errors" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body[:errors]).to contain_exactly("provider_trainee_id is too long (maximum is 50 characters)")
        end

        context "with enhanced errors" do
          let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

          it "returns errors" do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.parsed_body[:errors]).to eq(
              "provider_trainee_id" => ["is too long (maximum is 50 characters)"],
            )
          end
        end
      end
    end

    context "with application_id" do
      let(:params) do
        {
          data: data.merge(
            application_id:,
          ),
        }
      end

      before do
        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
      end

      context "when valid" do
        let(:application_id) { Faker::Number.number(digits: 7) }

        it "sets the correct application_id" do
          expect(response).to have_http_status(:created)
          expect(response.parsed_body[:data][:application_id]).to eq(application_id)

          expect(Trainee.last.application_choice_id).to eq(application_id)
        end
      end

      context "when invalid" do
        let(:application_id) { Faker::Number.number(digits: 8) }

        it "returns errors" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body[:errors]).to contain_exactly(
            "application_id is too long (maximum is 7 characters)",
          )
        end

        context "with enhanced errors" do
          let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

          it "returns errors" do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.parsed_body[:errors]).to eq(
              "application_id" => ["is too long (maximum is 7 characters)"],
            )
          end
        end
      end
    end

    context "with lead_partner_and_employing_school_attributes" do
      let(:fund_code) { Hesa::CodeSets::FundCodes::NOT_ELIGIBLE }

      before do
        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
      end

      context "when lead_partner_urn is blank and lead_partner_ukprn is blank" do
        let(:params) do
          {
            data: data.merge(
              lead_partner_ukprn: "",
              employing_school_urn: "900020",
            ),
          }
        end

        it "sets lead_partner_urn and employing_school_urn to nil" do
          expect(response.parsed_body[:lead_partner_urn]).to be_nil
          expect(response.parsed_body[:employing_school_urn]).to be_nil
        end

        it "sets lead_partner_not_applicable and employing_school_not_applicable to true" do
          trainee = Trainee.last

          expect(trainee.lead_partner_not_applicable).to be(true)
          expect(trainee.employing_school_not_applicable).to be(true)
        end
      end

      context "when lead_partner_urn is blank and lead_partner_ukprn is present and valid" do
        let(:lead_partner) { create(:lead_partner, :scitt) }
        let(:params) do
          {
            data: data.merge(
              lead_partner_ukprn: lead_partner.ukprn,
              employing_school_urn: "",
            ),
          }
        end

        it "sets lead_partner_ukprn to lead_partner#ukprn and employing_school_urn to nil" do
          expect(response.parsed_body[:data][:lead_partner_ukprn]).to eq(lead_partner.ukprn)
          expect(response.parsed_body[:data][:lead_partner_ukprn]).not_to be_nil
          expect(response.parsed_body[:data][:employing_school_urn]).to be_nil
        end

        it "sets lead_partner_not_applicable to false" do
          trainee = Trainee.last

          expect(trainee.lead_partner_not_applicable).to be(false)
        end
      end

      context "when lead_partner_urn is blank and lead_partner_ukprn is present but invalid" do
        let(:lead_partner) { create(:lead_partner, :scitt) }
        let(:params) do
          {
            data: data.merge(
              lead_partner_ukprn: "99999999",
              employing_school_urn: "",
            ),
          }
        end

        it "sets lead_partner_ukprn to lead_partner#ukprn and employing_school_urn to nil" do
          expect(response).to have_http_status(:unprocessable_entity)

          response.parsed_body[:data]
          expect(response.parsed_body["errors"]).to include(
            "lead_partner_id is invalid. The URN '99999999' does not match any known lead partners",
          )
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

          it "sets lead_partner_urn and employing_school_urn to nil" do
            expect(response.parsed_body[:data][:lead_partner_urn]).to be_nil
            expect(response.parsed_body[:data][:employing_school_urn]).to be_nil
          end

          it "sets lead_partner_not_applicable to true" do
            trainee = Trainee.last

            expect(trainee.lead_partner_not_applicable).to be(true)
          end
        end

        context "when lead_partner_urn is not a valid school urn (and not one of the special codes like 900020)" do
          let(:params) do
            {
              data: data.merge(
                lead_partner_urn: "123456",
                employing_school_urn: "",
              ),
            }
          end

          it "returns unprocessible entity HTTP code and a validation error message" do
            expect(response).to have_http_status(:unprocessable_entity)

            response.parsed_body[:data]
            expect(response.parsed_body["errors"]).to include(
              "lead_partner_id is invalid. The URN '123456' does not match any known lead partners",
            )
          end
        end

        context "when lead_partner_urn is an applicable school urn" do
          let(:params) do
            {
              data: data.merge(
                lead_partner_urn: lead_partner.urn,
                employing_school_urn: "",
              ),
            }
          end

          context "when lead_partner exists" do
            let(:lead_partner) { create(:lead_partner, :school) }

            it "sets lead_partner_urn to lead_partner#urn and employing_school_urn to nil" do
              expect(response.parsed_body[:data][:lead_partner_urn]).to eq(lead_partner.urn)
              expect(response.parsed_body[:data][:employing_school_urn]).to be_nil
            end

            it "sets lead_partner_not_applicable to false" do
              trainee = Trainee.last

              expect(trainee.lead_partner_not_applicable).to be(false)
            end
          end

          context "when lead_partner does not exist" do
            let(:lead_partner) { build(:school) }

            it "returns unprocessible entity HTTP code and a validation error message" do
              expect(response).to have_http_status(:unprocessable_entity)
              expect(response.parsed_body["errors"]).to include(
                "lead_partner_id is invalid. The URN '#{lead_partner.urn}' does not match any known lead partners",
              )
            end
          end
        end

        context "when employing_school_urn is present" do
          context "when lead_partner_urn is not an applicable school urn" do
            let(:params) do
              {
                data: data.merge(
                  lead_partner_urn: "900020",
                  employing_school_urn: "900030",
                ),
              }
            end

            it "sets employing_school_urn to nil" do
              expect(response.parsed_body[:data][:employing_school_urn]).to be_nil
            end

            it "sets employing_school_not_applicable to true" do
              trainee = Trainee.last

              expect(trainee.employing_school_not_applicable).to be(true)
            end
          end

          context "when lead_partner_urn is an applicable school urn" do
            let(:params) do
              {
                data: data.merge(
                  lead_partner_urn: "900020",
                  employing_school_urn: employing_school.urn,
                ),
              }
            end

            let(:employing_school) { create(:school) }

            it "sets employing_school_urn to employing_school#urn" do
              expect(response.parsed_body[:data][:employing_school_urn]).to eq(employing_school.urn)
            end

            it "sets employing_school_not_applicable to false" do
              trainee = Trainee.last

              expect(trainee.employing_school_not_applicable).to be(false)
            end
          end

          context "when applicable school urn is not valid" do
            let(:training_route) { Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:teacher_degree_apprenticeship]] }
            let(:params) do
              {
                data: data.merge(
                  lead_partner_urn: "900020",
                  employing_school_urn: "123456",
                ),
              }
            end

            let(:employing_school) { create(:school, urn: "456789") }

            it "returns unprocessible entity HTTP code and a validation error message" do
              expect(response).to have_http_status(:unprocessable_entity)
              expect(response.parsed_body["errors"]).to include(
                "employing_school_id is invalid. The URN '123456' does not match any known schools",
              )
            end
          end

          context "when lead_partner_urn and employing school urn are present and training route is `teacher_degree_apprenticeship`", "feature_routes.teacher_degree_apprenticeship": true do
            let(:params) do
              {
                data: data.merge(
                  lead_partner_urn: lead_partner.urn,
                  employing_school_urn: employing_school.urn,
                  training_route: Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:teacher_degree_apprenticeship]],
                ),
              }
            end

            let(:lead_partner) { create(:lead_partner, :school) }
            let(:employing_school) { create(:school) }

            it "sets employing_school_urn to employing_school#urn" do
              expect(response.parsed_body[:data][:employing_school_urn]).to eq(employing_school.urn)
            end

            it "sets employing_school_not_applicable to false" do
              trainee = Trainee.last

              expect(trainee.employing_school_not_applicable).to be(false)
            end

            it "sets lead_partner_urn to lead_partner#urn" do
              expect(response.parsed_body[:data][:lead_partner_urn]).to eq(lead_partner.urn)
            end
          end
        end
      end
    end

    context "when disabilities have the same code values" do
      let(:disability1) { "58" }
      let(:disability2) { "58" }

      it "does not create a trainee record and returns a 422 status with meaningful error message" do
        post "/api/v2025.0/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include("disabilities contain duplicate values")
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "does not create a trainee record and returns a 422 status with meaningful error message" do
          post "/api/v2025.0/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to eq(
            "disabilities" => ["contain duplicate values"],
          )
        end
      end
    end

    context "when `itt_start_date` is an invalid date" do
      let(:itt_start_date) { "2023-02-30" }

      before do
        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
      end

      it "does not create a trainee record and returns a 422 status with meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include("itt_start_date is invalid")
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "does not create a trainee record and returns a 422 status with meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            "itt_start_date" => ["is invalid"],
          )
        end
      end
    end

    context "when `itt_end_date` is before itt_start_date" do
      let(:itt_end_date) { "2022-01-30" }

      before do
        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
      end

      it "does not create a trainee record and returns a 422 status with meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include("itt_end_date must be after itt_start_date")
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "does not create a trainee record and returns a 422 status with meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to eq(
            "itt_end_date" => ["must be after itt_start_date"],
          )
        end
      end
    end

    context "when graduation_year is in 'yyyy-mm-dd' format" do
      let(:graduation_year) { "2003-01-01" }

      before do
        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
      end

      it "creates the degrees with the correct graduation_year" do
        degree_attributes = response.parsed_body[:data][:degrees]&.first

        expect(degree_attributes["graduation_year"]).to eq(2003)
      end
    end

    context "when graduation_year is a valid 4-digit integer" do
      let(:graduation_year) { 2003 }

      before do
        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
      end

      it "creates the degrees with the correct graduation_year" do
        degree_attributes = response.parsed_body[:data][:degrees]&.first

        expect(degree_attributes[:graduation_year]).to eq(2003)
      end
    end

    context "when graduation_year is an invalid 3-digit integer" do
      let(:graduation_year) { 200 }

      before do
        post "/api/v2025.0/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }
      end

      it "does not create a degree" do
        expect(response.parsed_body[:data]).to be_nil
        expect(response.parsed_body[:errors].first).to include("graduation_year is invalid")
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "does not create a degree" do
          expect(response.parsed_body[:data]).to be_nil
          expect(response.parsed_body[:errors]).to eq(
            "graduation_year" => ["is invalid"],
          )
        end
      end
    end

    context "when graduation_year is in an invalid format" do
      let(:graduation_year) { "abc" }

      before do
        post "/api/v2025.0/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }
      end

      it "does not create a degree" do
        expect(response.parsed_body[:data]).to be_nil
        expect(response.parsed_body[:errors]).to contain_exactly("graduation_year is invalid")
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "does not create a degree" do
          expect(response.parsed_body[:data]).to be_nil
          expect(response.parsed_body[:errors]).to eq(
            "graduation_year" => ["is invalid"],
          )
        end
      end
    end

    it "creates the placements if provided in the request body" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      placement_attributes = response.parsed_body[:data][:placements]&.first
      expect(placement_attributes[:school_id]).to be_nil
      expect(placement_attributes[:name]).to eq("Establishment does not have a URN")
      expect(placement_attributes[:urn]).to eq("900020")
    end

    it "returns status 201" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response).to have_http_status(:created)
    end

    it "creates the nationalities" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(Trainee.last.nationalities.first.name).to eq("british")
    end

    it "sets the correct course allocation subject" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(Trainee.last.course_allocation_subject).to eq(course_allocation_subject)
    end

    it "sets the progress data structure" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(Trainee.last.progress.personal_details).to be(true)
    end

    it "sets the record source to `api`" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(Trainee.last.api_record?).to be(true)
    end

    it "sets the provider_trainee_id" do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(Trainee.last.provider_trainee_id).to eq("99157234/2/01")
    end

    context "when read only attributes are submitted", openapi: false do
      let(:trn) { "567899" }
      let(:ethnic_group) { "mixed_ethnic_group" }
      let(:ethnic_background) { "Another Mixed background" }

      before do
        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
      end

      context "when the ethnicity is provided" do
        let(:params) do
          {
            data: data.merge(
              trn:,
              ethnicity:,
              ethnic_group:,
              ethnic_background:,
            ),
          }
        end

        let(:ethnicity) { "899" }

        it "sets the ethnic attributes based on ethnicity" do
          expect(response).to have_http_status(:created)

          trainee = Trainee.last

          expect(trainee.trn).to be_nil
          expect(trainee.ethnic_group).to eq("other_ethnic_group")
          expect(trainee.ethnic_background).to eq("Another ethnic background")

          parsed_body = response.parsed_body[:data]

          expect(parsed_body[:trn]).to be_nil
          expect(parsed_body[:ethnicity]).to eq(ethnicity)
          expect(parsed_body[:ethnic_group]).to eq(trainee.ethnic_group)
          expect(parsed_body[:ethnic_background]).to eq(trainee.ethnic_background)
        end
      end

      context "when the ethnicity is not provided" do
        let(:params) do
          {
            data: data.merge(
              trn:,
              ethnic_group:,
              ethnic_background:,
            ),
          }
        end

        it "sets the ethnic attributes to not provided" do
          expect(response).to have_http_status(:created)

          trainee = Trainee.last

          expect(trainee.trn).to be_nil
          expect(trainee.ethnic_group).to eq("not_provided_ethnic_group")
          expect(trainee.ethnic_background).to eq("Not provided")

          parsed_body = response.parsed_body[:data]

          expect(parsed_body[:trn]).to be_nil
          expect(parsed_body[:ethnicity]).to eq("997")
          expect(parsed_body[:ethnic_group]).to eq("not_provided_ethnic_group")
          expect(parsed_body[:ethnic_background]).to eq("Not provided")
        end
      end
    end

    context "with course subjects" do
      context "when there course_subject_two is a duplicate" do
        before do
          post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
        end

        let(:params) do
          {
            data: data.merge(
              course_subject_one: Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::BIOLOGY],
              course_subject_two: Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::BIOLOGY],
            ),
          }
        end

        it do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body[:errors]).to contain_exactly(
            "course_subject_two might contain duplicate values",
          )
        end

        context "with enhanced errors" do
          let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

          it do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.parsed_body[:errors]).to eq(
              "course_subject_two" => ["might contain duplicate values"],
            )
          end
        end
      end

      context "when there course_subject_three is a duplicate" do
        before do
          post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
        end

        let(:params) do
          {
            data: data.merge(
              course_subject_one: Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::PRIMARY_TEACHING],
              course_subject_two: Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::BIOLOGY],
              course_subject_three: Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::BIOLOGY],
            ),
          }
        end

        it do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body[:errors]).to contain_exactly(
            "course_subject_three might contain duplicate values",
          )
        end

        context "with enhanced errors" do
          let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

          it do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.parsed_body[:errors]).to eq(
              "course_subject_three" => ["might contain duplicate values"],
            )
          end
        end
      end

      context "when HasCourseAttributes#primary_education_phase? is true" do
        let(:course_age_range) { "13914" }

        before do
          post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
        end

        context "when '100511' is not present" do
          let(:params) do
            {
              data: data.merge(
                course_subject_one: "100346",
                course_subject_two: "101410",
                course_subject_three: "100366",
              ),
            }
          end

          it "sets the correct subjects" do
            trainee = Trainee.last

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
              data: data.merge(
                course_subject_one: "100511",
                course_subject_two: "101410",
                course_subject_three: "100366",
              ),
            }
          end

          it "sets the correct subjects" do
            trainee = Trainee.last

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
        let(:course_age_range) { "13917" }
        let(:params) do
          {
            data: data.merge(
              course_subject_one: "100346",
              course_subject_two: "101410",
              course_subject_three: "100366",
            ),
          }
        end

        before do
          post endpoint, params: params, headers: { Authorization: token }, as: :json
        end

        it "sets the correct subjects" do
          trainee = Trainee.last

          expect(trainee.course_subject_one).to eq("biology")
          expect(trainee.course_subject_two).to eq("historical linguistics")
          expect(trainee.course_subject_three).to eq("computer science")

          expect(response.parsed_body[:data][:course_subject_one]).to eq("100346")
          expect(response.parsed_body[:data][:course_subject_two]).to eq("101410")
          expect(response.parsed_body[:data][:course_subject_three]).to eq("100366")
        end
      end
    end

    context "with ethnicity" do
      before do
        post endpoint, params: params, headers: { Authorization: token, **json_headers }, as: :json
      end

      context "when present" do
        let(:params) do
          {
            data: data.merge(
              ethnicity:,
            ),
          }
        end

        let(:ethnicity) { "142" }

        it do
          expect(response).to have_http_status(:created)
          expect(response.parsed_body[:data][:ethnicity]).to eq(ethnicity)
        end
      end

      context "when not present" do
        it do
          expect(response).to have_http_status(:created)
          expect(response.parsed_body[:data][:ethnicity]).to eq("997")
        end
      end

      context "when invalid" do
        let(:params) do
          {
            data: data.merge(
              ethnicity: "1000",
            ),
          }
        end

        it do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body[:errors]).to include(
            /ethnicity has invalid reference data value of '1000'/,
          )
        end

        context "with enhanced errors" do
          let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

          it do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.parsed_body[:errors]).to include(
              "ethnicity" => [/has invalid reference data value of '1000'/],
            )
          end
        end
      end
    end

    context "with training_route" do
      context "when present" do
        let(:params) do
          {
            data: data.merge(
              itt_start_date:,
              training_route:,
            ),
          }
        end

        let(:itt_start_date) { "2023-01-01" }
        let(:training_route) { Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_undergrad]] }

        before do
          post endpoint, params: params, headers: { Authorization: token, **json_headers }, as: :json
        end

        it do
          expect(response).to have_http_status(:created)
          expect(response.parsed_body[:data][:training_route]).to eq(training_route)
        end

        context "when the degrees are missing" do
          let(:degrees_attributes) { [] }

          it do
            expect(response).to have_http_status(:created)
            expect(response.parsed_body[:data][:training_route]).to eq(training_route)
          end
        end
      end

      context "when not present" do
        let(:params) do
          {
            data: data.merge(
              training_route:,
            ),
          }
        end

        let(:training_route) { nil }

        before do
          post endpoint, params: params, headers: { Authorization: token, **json_headers }, as: :json
        end

        it do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body[:errors]).to contain_exactly(
            "training_route can't be blank",
          )
        end

        context "with enhanced errors" do
          let(:json_headers) { { "HTTP_ENHANCED_ERRORS" => "true" } }

          it do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.parsed_body[:errors]).to eq(
              "training_route" => ["can't be blank"],
            )
          end
        end
      end

      describe "provider_led_postgrad training route" do
        let(:params) do
          {
            data: data.merge(
              itt_start_date: itt_start_date,
              itt_end_date: itt_end_date,
              trainee_start_date: itt_start_date,
              training_route: Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_postgrad]],
            ),
          }
        end

        let(:json_headers) do
          {
            Authorization: token,
          }
        end

        before do
          Timecop.travel(itt_start_date)

          post endpoint, params: params, headers: json_headers, as: :json
        end

        context "when invalid - provider_led_postgrad before 2022" do
          let!(:academic_cycle) { create(:academic_cycle, cycle_year:) }

          let(:itt_start_date) { "2021-08-01" }
          let(:itt_end_date)   { "2022-01-01" }
          let(:cycle_year) { 2021 }

          it do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.parsed_body[:errors]).to include(
              /training_route has invalid reference data value of/,
            )
          end

          context "with enhanced errors" do
            let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

            it do
              expect(response).to have_http_status(:unprocessable_entity)
              expect(response.parsed_body[:errors]).to include(
                "training_route" => [/has invalid reference data value of/],
              )
            end
          end
        end

        context "when valid - provider_led_postgrad after 2022" do
          let!(:academic_cycle) { create(:academic_cycle, cycle_year:) }

          let(:itt_start_date) { "2023-08-01" }
          let(:itt_end_date)   { "2024-01-01" }
          let(:cycle_year) { 2023 }

          it do
            expect(response).to have_http_status(:created)
            expect(response.parsed_body[:errors]).to be_blank
          end
        end

        context "when the degrees are missing" do
          let(:degrees_attributes) { [] }

          it "is invalid" do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.parsed_body[:errors]).to contain_exactly(
              "degrees_attributes must be entered if specifying a postgraduate training_route",
            )
          end

          context "with enhanced errors" do
            let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

            it "is invalid" do
              expect(response).to have_http_status(:unprocessable_entity)
              expect(response.parsed_body[:errors]).to eq(
                "degrees_attributes" => ["must be entered if specifying a postgraduate training_route"],
              )
            end
          end
        end
      end
    end
  end

  context "when the trainee record has invalid reference data values" do
    before do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
    end

    let(:cycle_year) { 2022 }
    let(:params) { { data: { email: "Doe" } } }
    let!(:academic_cycle) { create(:academic_cycle, cycle_year:) }

    it "return status code 422 with a meaningful error message" do
      expect(response).to have_http_status(:unprocessable_entity)

      expect(response.parsed_body["errors"]).to contain_exactly("first_names can't be blank", "last_name can't be blank", "date_of_birth can't be blank", "sex can't be blank", "training_route can't be blank", "itt_start_date can't be blank", "itt_end_date can't be blank", "course_subject_one can't be blank", "study_mode can't be blank", "hesa_id can't be blank", "email Enter an email address in the correct format, like name@example.com", "itt_aim can't be blank", "itt_qualification_aim must be entered if 202 selected for itt_aim", "course_year can't be blank", "course_age_range can't be blank", "fund_code can't be blank", "funding_method can't be blank")
    end

    context "with enhanced errors" do
      let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to eq(
          "first_names" => ["can't be blank"],
          "last_name" => ["can't be blank"],
          "date_of_birth" => ["can't be blank"],
          "sex" => ["can't be blank"],
          "training_route" => ["can't be blank"],
          "itt_start_date" => ["can't be blank"],
          "itt_end_date" => ["can't be blank"],
          "course_subject_one" => ["can't be blank"],
          "study_mode" => ["can't be blank"],
          "hesa_id" => ["can't be blank"],
          "email" => ["Enter an email address in the correct format, like name@example.com"],
          "itt_aim" => ["can't be blank"],
          "itt_qualification_aim" => ["must be entered if 202 selected for itt_aim"],
          "course_year" => ["can't be blank"],
          "course_age_range" => ["can't be blank"],
          "fund_code" => ["can't be blank"],
          "funding_method" => ["can't be blank"],
        )
      end
    end

    context "date of birth is in the future" do
      let(:params) { { data: data.merge({ date_of_birth: "2990-01-01" }) } }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("date_of_birth must be in the past")
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to eq(
            "date_of_birth" => ["must be in the past"],
          )
        end
      end
    end

    context "itt_start_date is in the future but within next year" do
      let(:params) { { data: data.merge({ itt_start_date: 1.month.from_now.iso8601, itt_end_date: 2.months.from_now.iso8601, trainee_start_date: Date.current.iso8601 }) } }

      it "creates a successful response" do
        expect(response).to have_http_status(:created)
      end
    end

    context "itt_start_date is beyond next year" do
      let(:params) { { data: data.merge({ itt_start_date: 2.years.from_now.beginning_of_year.iso8601, itt_end_date: 2.years.from_now.beginning_of_year.advance(months: 6).iso8601, trainee_start_date: Date.current.iso8601 }) } }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include("itt_start_date must not be more than one year in the future")
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            "itt_start_date" => ["must not be more than one year in the future"],
          )
        end
      end
    end

    context "when course_age_range is empty" do
      let(:params) { { data: } }

      let(:course_age_range) { "" }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("course_age_range can't be blank")
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to eq(
            "course_age_range" => ["can't be blank"],
          )
        end
      end
    end

    context "when course_age_range has invalid reference data values" do
      let(:params) { { data: } }

      let(:course_age_range) { "1234" }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include(
          /course_age_range has invalid reference data value of '1234'/,
        )
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            "course_age_range" => [/has invalid reference data value of '1234'/],
          )
        end
      end
    end

    context "when sex is empty" do
      let(:params) { { data: } }
      let(:sex) { "" }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("sex can't be blank")
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to eq(
            "sex" => ["can't be blank"],
          )
        end
      end
    end

    context "when sex has invalid reference data values" do
      let(:params) { { data: } }

      let(:sex) { "3" }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include(
          /sex has invalid reference data value of '3'/,
        )
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            "sex" => [/has invalid reference data value of '3'/],
          )
        end
      end
    end

    context "when ethnicity has invalid reference data values" do
      let(:ethnicity) { "Irish" }
      let(:params) { { data: data.merge(ethnicity:) } }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include(
          /ethnicity has invalid reference data value of 'Irish'/,
        )
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            "ethnicity" => [/has invalid reference data value of 'Irish'/],
          )
        end
      end
    end

    context "when course_subject_one has invalid reference data values" do
      let(:course_subject_one) { "chemistry" }
      let(:params) do
        { data: data.merge({ course_subject_one: }) }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include(
          /course_subject_one has invalid reference data value of 'chemistry'/,
        )
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            "course_subject_one" => [/has invalid reference data value of 'chemistry'/],
          )
        end
      end
    end

    context "when course_subject_two has invalid reference data values" do
      let(:course_subject_two) { "child development" }
      let(:params) do
        { data: data.merge({ course_subject_two: }) }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include(
          /course_subject_two has invalid reference data value of/,
        )
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            "course_subject_two" => [/has invalid reference data value of/],
          )
        end
      end
    end

    context "when course_subject_three has invalid reference data values" do
      let(:course_subject_three) { "classical studies" }
      let(:params) do
        { data: data.merge({ course_subject_three: }) }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include(
          /course_subject_three has invalid reference data value of/,
        )
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            "course_subject_three" => [/has invalid reference data value of/],
          )
        end
      end
    end

    context "when study_mode has invalid reference data values" do
      let(:study_mode) { 1 }
      let(:params) do
        { data: data.merge({ study_mode: }) }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include(
          /study_mode has invalid reference data value of '1'/,
        )
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            "study_mode" => [/has invalid reference data value of '1'/],
          )
        end
      end
    end

    context "when nationality has invalid reference data values" do
      let(:nationality) { "british" }
      let(:params) do
        { data: data.merge({ nationality: }) }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include(
          /nationality has invalid reference data value of 'british'/,
        )
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            "nationality" => [/has invalid reference data value of 'british'/],
          )
        end
      end
    end

    context "when training_initiative has invalid reference data values" do
      let(:training_initiative) { "now_teach" }
      let(:params) do
        { data: data.merge({ training_initiative: }) }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include(
          /training_initiative has invalid reference data value of 'now_teach'/,
        )
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            "training_initiative" => [/has invalid reference data value of 'now_teach'/],
          )
        end
      end
    end

    context "when funding_method has invalid reference data values" do
      let(:funding_method) { "8c629dd7-bfc3-eb11-bacc-000d3addca7a" }
      let(:params) do
        { data: data.merge({ funding_method: }) }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include(
          /funding_method has invalid reference data value of '8c629dd7-bfc3-eb11-bacc-000d3addca7a'/,
        )
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            "funding_method" => [/has invalid reference data value of '8c629dd7-bfc3-eb11-bacc-000d3addca7a'/],
          )
        end
      end
    end

    context "when itt_aim has invalid reference data values" do
      let(:itt_aim) { "321" }
      let(:params) do
        { data: data.merge({ itt_aim: }) }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include(
          /itt_aim has invalid reference data value of '321'/,
        )
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            "itt_aim" => [/has invalid reference data value of '321'/],
          )
        end
      end
    end

    context "when itt_qualification_aim has invalid reference data values" do
      let(:itt_qualification_aim) { "321" }
      let(:params) do
        { data: data.merge({ itt_qualification_aim: }) }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include(
          /itt_qualification_aim has invalid reference data value of '321'/,
        )
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include(
            "itt_qualification_aim" => [/has invalid reference data value of \'321\'/],
          )
        end
      end
    end
  end

  context "when a placement has invalid reference data values" do
    before do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
    end

    let(:params) { { data: data.merge({ placements_attributes: [{ not_an_attribute: "invalid" }] }) } }

    it "return status code 422 with a meaningful error message" do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["errors"]).to include("placements_attributes name can't be blank")
    end

    context "with enhanced errors" do
      let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include(
          "placements_attributes" => ["name can't be blank"],
        )
      end
    end
  end

  context "when only a placement urn is provided", feature_register_api: true do
    before do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
    end

    let(:school) { create(:school) }
    let(:params) { { data: data.merge({ placements_attributes: [{ urn: school.urn }] }) } }

    it "creates the placement" do
      placement_attributes = response.parsed_body[:data][:placements]&.first

      expect(placement_attributes[:urn]).to eq(school.urn)
      expect(placement_attributes[:name]).to eq(school.name)
    end
  end

  context "when a degree has invalid reference data values" do
    before do
      params[:data][:degrees_attributes].first[:graduation_year] = "3000-01-01"

      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
    end

    it "return status code 422 with a meaningful error message" do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["message"]).to eq("Validation failed: 2 errors prohibited this trainee from being saved")
      expect(response.parsed_body["errors"]).to contain_exactly(
        "graduation_year must be in the past, for example 2014",
        "graduation_year is invalid",
      )
    end

    context "with enhanced errors" do
      let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["message"]).to include("Validation failed: 2 errors prohibited this trainee from being saved")
        expect(response.parsed_body["errors"]).to include(
          "graduation_year" => [
            "must be in the past, for example 2014",
            "is invalid",
          ],
        )
      end
    end

    context "with invalid degree attributes" do
      before do
        params[:data][:degrees_attributes].first[:uk_degree] = "Bachelor of Arts"

        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response.parsed_body["message"]).to eq("Validation failed: 3 errors prohibited this trainee from being saved")
        expect(response.parsed_body["errors"]).to contain_exactly(
          "graduation_year must be in the past, for example 2014",
          "graduation_year is invalid",
          /uk_degree has invalid reference data value of 'Bachelor of Arts'/,
        )
      end

      context "with enhanced errors" do
        let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

        it "return status code 422 with a meaningful error message" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["message"]).to eq("Validation failed: 3 errors prohibited this trainee from being saved")
          expect(response.parsed_body["errors"]).to match(
            "graduation_year" => ["must be in the past, for example 2014", "is invalid"],
            "uk_degree" => [/has invalid reference data value of 'Bachelor of Arts'./],
          )
        end
      end
    end
  end

  context "with duplicate degree attributes" do
    before do
      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
    end

    let(:degrees_attributes) {
      [
        {
          grade: "02",
          subject: "100485",
          institution: "0117",
          uk_degree: "083",
          graduation_year: "1999",
        },
        {
          grade: "02",
          subject: "100485",
          institution: "0117",
          uk_degree: "083",
          graduation_year: "1999",
        },
      ]
    }

    it "return status code 422 with a meaningful error message" do
      expect {
        post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
      }.not_to change {
        Trainee.count
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body[:errors]).to contain_exactly(
        "degrees_attributes contains duplicate degrees",
      )
    end
  end

  context "when a degree is missing" do
    before do
      params[:data][:degrees_attributes].first.delete(:uk_degree)

      post endpoint, params: params.to_json, headers: { Authorization: token, **json_headers }
    end

    it "return status code 422 with a meaningful error message" do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["message"]).to include("Validation failed: 1 error prohibited this trainee from being saved")
      expect(response.parsed_body["errors"]).to include("uk_degree must be entered if specifying a previous UK degree")
    end

    context "with enhanced errors" do
      let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["message"]).to include("Validation failed: 1 error prohibited this trainee from being saved")
        expect(response.parsed_body["errors"]).to include(
          "uk_degree" => ["must be entered if specifying a previous UK degree"],
        )
      end
    end
  end

  context "with a fund_code that is ineligible for funding" do
    before do
      params[:data][:training_route] = Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:teacher_degree_apprenticeship]]
      params[:data][:fund_code] = Hesa::CodeSets::FundCodes::NOT_ELIGIBLE
      params[:data][:funding_method] = Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY
      params[:data][:course_subject_one] = Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::BIOLOGY]

      post "/api/v2025.0/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }
    end

    it "return status code 422 with a meaningful error message" do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["message"]).to eq(
        "Validation failed: 1 error prohibited this trainee from being saved",
      )
      expect(response.parsed_body["errors"]).to contain_exactly(
        "funding_method 'bursary' is not allowed when fund_code is '2' and course_subject_one is 'biology'",
      )
    end

    context "with enhanced errors" do
      let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["message"]).to eq(
          "Validation failed: 1 error prohibited this trainee from being saved",
        )
        expect(response.parsed_body["errors"]).to eq(
          "funding_method" => [
            "'bursary' is not allowed when fund_code is '2' and course_subject_one is 'biology'",
          ],
        )
      end
    end
  end

  context "with a fund_code that is eligible for funding because it has a special case course subject" do
    let!(:academic_cycle) do
      create(
        :academic_cycle,
        start_date: Date.new(2025, 8, 1),
        end_date: Date.new(2026, 7, 31),
      )
    end

    before do
      params[:data][:training_route] = Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_postgrad]]
      params[:data][:fund_code] = Hesa::CodeSets::FundCodes::NOT_ELIGIBLE
      params[:data][:funding_method] = Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY
      params[:data][:course_subject_one] = Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::FRENCH_LANGUAGE]
      funding_rule = create(
        :funding_method,
        training_route: :provider_led_postgrad,
        funding_type: :bursary,
        academic_cycle: academic_cycle,
      )
      create(
        :funding_method_subject,
        funding_method: funding_rule,
        allocation_subject: french_allocation_subject,
      )

      post "/api/v2025.0/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }
    end

    it "returns success status code with no errors" do
      expect(response).to have_http_status(:created)
      expect(response.parsed_body["message"]).to be_blank
    end
  end

  context "when the hesa_id has an invalid length" do
    before do
      params[:data][:hesa_id] = SecureRandom.random_number(10 * 12).to_s

      post "/api/v2025.0/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }
    end

    it "returns status 422 with a meaningful error message" do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["message"]).to eq(
        "Validation failed: 1 error prohibited this trainee from being saved",
      )
      expect(response.parsed_body["errors"]).to contain_exactly(
        "hesa_id must be 13 or 17 characters",
      )
    end

    context "with enhanced errors" do
      let(:json_headers) { super().merge("HTTP_ENHANCED_ERRORS" => "true") }

      it "returns status 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["message"]).to eq(
          "Validation failed: 1 error prohibited this trainee from being saved",
        )
        expect(response.parsed_body["errors"]).to eq(
          "hesa_id" => ["must be 13 or 17 characters"],
        )
      end
    end
  end
end
