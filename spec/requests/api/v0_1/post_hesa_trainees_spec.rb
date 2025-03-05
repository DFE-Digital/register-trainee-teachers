# frozen_string_literal: true

require "rails_helper"

describe "`POST /api/v0.1/trainees` endpoint" do
  let(:token) { "trainee_token" }
  let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }
  let!(:nationality) { create(:nationality, :british) }

  let!(:course_allocation_subject) do
    create(:subject_specialism, name: CourseSubjects::BIOLOGY).allocation_subject
  end

  let(:params) { { data: } }

  let(:graduation_year) { "2003" }
  let(:course_age_range) { Hesa::CodeSets::AgeRanges::MAPPING.keys.sample }
  let(:sex) { Hesa::CodeSets::Sexes::MAPPING.keys.sample }
  let(:itt_start_date) { "2023-01-01" }
  let(:itt_end_date) { "2023-10-01" }

  let(:data) do
    {
      first_names: "John",
      last_name: "Doe",
      previous_last_name: "Smith",
      date_of_birth: "1990-01-01",
      sex: sex,
      email: "john.doe@example.com",
      nationality: "GB",
      training_route: Hesa::CodeSets::TrainingRoutes::MAPPING.invert[TRAINING_ROUTE_ENUMS[:provider_led_undergrad]],
      itt_start_date: itt_start_date,
      itt_end_date: itt_end_date,
      course_subject_one: Hesa::CodeSets::CourseSubjects::MAPPING.invert[CourseSubjects::BIOLOGY],
      study_mode: Hesa::CodeSets::StudyModes::MAPPING.invert[TRAINEE_STUDY_MODE_ENUMS["full_time"]],
      disability1: "58",
      disability2: "57",
      degrees_attributes: [
        {
          grade: "02",
          subject: "100485",
          institution: "0117",
          uk_degree: "083",
          graduation_year: graduation_year,
        },
        {
          grade: "02",
          subject: "100485",
          non_uk_degree: "097",
          country: "MX",
          graduation_year: graduation_year,
        },
      ],
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
      fund_code: "7",
      funding_method: "4",
      hesa_id: "0310261553101",
      provider_trainee_id: "99157234/2/01",
      pg_apprenticeship_start_date: "2024-03-11",
      application_id: 123456,
    }
  end

  before do
    create(:disability, :blind)
    create(:disability, :deaf)
  end

  context "when the request is valid" do
    before do
      allow(Api::V01::HesaMapper::Attributes).to receive(:call).and_call_original
      allow(Trainees::MapFundingFromDttpEntityId).to receive(:call).and_call_original
    end

    it "creates a trainee" do
      post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response.parsed_body[:data][:first_names]).to eq("John")
      expect(response.parsed_body[:data][:last_name]).to eq("Doe")
      expect(response.parsed_body[:data][:previous_last_name]).to eq("Smith")
      expect(response.parsed_body[:data][:pg_apprenticeship_start_date]).to eq("2024-03-11")
    end

    it "sets the correct state" do
      post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(Trainee.last.state).to eq("submitted_for_trn")
    end

    it "sets the correct course_min_age and course_max_age" do
      course_min_age, course_max_age = DfE::ReferenceData::AgeRanges::HESA_CODE_SETS[course_age_range]

      post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response.parsed_body[:data][:course_min_age]).to eq(course_min_age)
      expect(response.parsed_body[:data][:course_max_age]).to eq(course_max_age)
    end

    it "sets the correct study_mode" do
      post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response.parsed_body[:data][:study_mode]).to eq("63")
    end

    it "sets the correct application_id" do
      post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(Trainee.last.application_choice_id).to be(123456)
      expect(response.parsed_body[:data][:application_id]).to eq(123456)
    end

    it "sets the correct disabilities" do
      post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }

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
      post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }

      parsed_body = response.parsed_body[:data]

      expect(Trainees::MapFundingFromDttpEntityId).to have_received(:call).once
      expect(Trainee.last.applying_for_scholarship).to be(true)
      expect(Trainee.last.applying_for_bursary).to be(false)
      expect(Trainee.last.applying_for_grant).to be(false)
      expect(parsed_body[:fund_code]).to eq("7")
      expect(parsed_body[:bursary_level]).to eq("4")
      expect(parsed_body[:applying_for_scholarship]).to be_nil
      expect(parsed_body[:applying_for_bursary]).to be_nil
      expect(parsed_body[:applying_for_grant]).to be_nil
    end

    it "sets the correct school attributes" do
      post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }

      parsed_body = response.parsed_body[:data]

      expect(parsed_body[:lead_partner_not_applicable]).to be(true)
      expect(parsed_body[:lead_partner]).to be_nil
      expect(parsed_body[:employing_school_not_applicable]).to be(true)
      expect(parsed_body[:employing_school]).to be_nil
    end

    it "creates the degrees if provided in the request body" do
      post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }

      first_degree_attributes, second_degree_attributes =
        response.parsed_body[:data][:degrees]

      expect(first_degree_attributes[:subject]).to eq("100485")
      expect(first_degree_attributes[:institution]).to eq("0117")
      expect(first_degree_attributes[:graduation_year]).to eq(2003)
      expect(first_degree_attributes[:subject]).to eq("100485")
      expect(first_degree_attributes[:grade]).to eq("02")
      expect(first_degree_attributes[:uk_degree]).to eq("083")
      expect(first_degree_attributes[:country]).to be_nil

      expect(second_degree_attributes[:grade]).to eq("02")
      expect(second_degree_attributes[:subject]).to eq("100485")
      expect(second_degree_attributes[:non_uk_degree]).to eq("097")
      expect(second_degree_attributes[:country]).to eq("MX")
      expect(second_degree_attributes[:graduation_year]).to eq(2003)

      first_degree, second_degree = Degree.all

      expect(first_degree.locale_code).to eq("uk")
      expect(first_degree.subject).to eq("Law")
      expect(first_degree.institution).to eq("University of East Anglia")
      expect(first_degree.graduation_year).to eq(2003)
      expect(first_degree.grade).to eq("Upper second-class honours (2:1)")
      expect(first_degree.uk_degree).to eq("Bachelor of Science")
      expect(first_degree.country).to be_nil

      expect(second_degree.locale_code).to eq("non_uk")
      expect(second_degree.subject).to eq("Law")
      expect(second_degree.institution).to be_nil
      expect(second_degree.graduation_year).to eq(2003)
      expect(second_degree.grade).to eq("Upper second-class honours (2:1)")
      expect(second_degree.uk_degree).to be_nil
      expect(second_degree.non_uk_degree).to eq("Bachelor of Education Scotland and Northern Ireland")
      expect(second_degree.country).to eq("Mexico")
    end

    context "with lead_partner and employing_school attributes" do
      before do
        post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }
      end

      context "when lead_partner_urn is blank" do
        before do
          data.merge(
            lead_partner_urn: "",
            employing_school_urn: "900021",
          )
        end

        it "sets lead_partner_urn and employing_school_urn to nil" do
          expect(response.parsed_body[:data][:lead_partner_urn]).to be_nil
          expect(response.parsed_body[:data][:employing_school_urn]).to be_nil
        end

        it "sets lead_partner_not_applicable and employing_school_not_applicable to false" do
          expect(response.parsed_body[:data][:lead_partner_not_applicable]).to be(true)
          expect(response.parsed_body[:data][:employing_school_not_applicable]).to be(true)
        end
      end

      context "when lead_partner_urn is present" do
        context "when lead_partner_urn is not an applicable shool urn" do
          let(:params) do
            {
              data: data.merge(
                lead_partner_urn: "900020",
                employing_school_urn: "",
              ),
            }
          end

          it "sets lead_partner_urn and employing_school_urn to nil" do
            expect(response.parsed_body[:data]).to have_key(:lead_partner_urn)
            expect(response.parsed_body[:data][:lead_partner_urn]).to be_nil
            expect(response.parsed_body[:data][:employing_school_urn]).to be_nil
          end

          it "sets lead_partner_not_applicable to true" do
            expect(response.parsed_body[:data][:lead_partner_not_applicable]).to be(true)
          end
        end

        context "when lead_partner_urn is an applicable partner urn" do
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
              expect(response.parsed_body[:data][:lead_partner_not_applicable]).to be(false)
            end
          end

          context "when lead_partner does not exist" do
            let(:lead_partner) { build(:lead_partner, :school) }

            it "sets lead_partner_urn and employing_school_urn to nil" do
              expect(response.parsed_body[:data]).to have_key(:lead_partner_urn)
              expect(response.parsed_body[:data][:lead_partner_urn]).to be_nil
              expect(response.parsed_body[:data][:employing_school_urn]).to be_nil
            end

            it "sets lead_partner_not_applicable to true" do
              expect(response.parsed_body[:data][:lead_partner_not_applicable]).to be(true)
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
              expect(response.parsed_body[:data]).to have_key(:employing_school_urn)
              expect(response.parsed_body[:data][:employing_school_urn]).to be_nil
            end

            it "sets employing_school_not_applicable to true" do
              expect(response.parsed_body[:data][:employing_school_not_applicable]).to be(true)
            end
          end

          context "when lead_partner_urn is an applicable lead partner urn" do
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
              expect(response.parsed_body[:data][:employing_school_not_applicable]).to be(false)
            end
          end
        end
      end
    end

    context "when `itt_start_date` is an invalid date" do
      let(:itt_start_date) { "2023-02-30" }

      before do
        post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }
      end

      it "does not create a trainee record and returns a 422 status with meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include("Itt start date is invalid")
      end
    end

    context "when graduation_year is in 'yyyy-mm-dd' format" do
      let(:graduation_year) { "2003-01-01" }

      before do
        post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }
      end

      it "creates the degrees with the correct graduation_year" do
        degree_attributes = response.parsed_body[:data][:degrees]&.first

        expect(degree_attributes["graduation_year"]).to eq(2003)
      end
    end

    context "when graduation_year is a valid 4-digit integer" do
      let(:graduation_year) { 2003 }

      before do
        post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }
      end

      it "creates the degrees with the correct graduation_year" do
        degree_attributes = response.parsed_body[:data][:degrees]&.first

        expect(degree_attributes[:graduation_year]).to eq(2003)
      end
    end

    context "when graduation_year is an invalid 3-digit integer" do
      let(:graduation_year) { 200 }

      before do
        post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }
      end

      it "does not create a degree" do
        expect(response.parsed_body[:data]).to be_nil
        expect(response.parsed_body[:errors].first).to include("Enter a valid graduation year")
      end
    end

    context "when graduation_year is in an invalid format" do
      let(:graduation_year) { "abc" }

      before do
        post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }
      end

      it "does not create a degree" do
        expect(response.parsed_body[:data]).to be_nil
        expect(response.parsed_body[:errors].first).to include("Enter a valid graduation year")
      end
    end

    it "creates the placements if provided in the request body" do
      post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }

      placement_attributes = response.parsed_body[:data][:placements]&.first

      expect(placement_attributes[:school_id]).to be_nil
      expect(placement_attributes[:name]).to eq("Establishment does not have a URN")
      expect(placement_attributes[:urn]).to eq("900020")
    end

    it "returns status code 201" do
      post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(response).to have_http_status(:created)
    end

    it "creates the nationalities" do
      post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(Trainee.last.nationalities.first.name).to eq("british")
    end

    it "sets the correct course allocation subject" do
      post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(Trainee.last.course_allocation_subject).to eq(course_allocation_subject)
    end

    it "sets the progress data structure" do
      post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(Trainee.last.progress.personal_details).to be(true)
    end

    it "sets the record source to `api`" do
      post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(Trainee.last.api_record?).to be(true)
    end

    it "sets the provider_trainee_id" do
      post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }

      expect(Trainee.last.provider_trainee_id).to eq("99157234/2/01")
    end

    context "when read only attributes are submitted", openapi: false do
      let(:trn) { "567899" }
      let(:ethnic_group) { "mixed_ethnic_group" }
      let(:ethnic_background) { "Another Mixed background" }

      before do
        post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }
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
      context "when HasCourseAttributes#primary_education_phase? is true" do
        let(:course_age_range) { "13914" }

        before do
          post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }
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
          post "/api/v0.1/trainees", params: params, headers: { Authorization: token }, as: :json
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
        post "/api/v0.1/trainees", params: params, headers: { Authorization: token }, as: :json
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
          expect(response.parsed_body[:errors]).to contain_exactly("Ethnicity has invalid reference data values")
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
          post "/api/v0.1/trainees", params: params, headers: { Authorization: token }, as: :json
        end

        it do
          expect(response).to have_http_status(:created)
          expect(response.parsed_body[:data][:training_route]).to eq(training_route)
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
          post "/api/v0.1/trainees", params: params, headers: { Authorization: token }, as: :json
        end

        it do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body[:errors]).to contain_exactly("Training route can't be blank")
        end
      end

      context "when invalid" do
        let(:params) do
          {
            data: data.merge(
              itt_start_date: itt_start_date,
              itt_end_date: itt_end_date,
              training_route: "opt_in_undergrad",
            ),
          }
        end

        let(:itt_start_date) { "2024-08-01" }
        let(:itt_end_date)   { "2025-01-01" }

        let!(:academic_cycle) { create(:academic_cycle, cycle_year: 2024) }

        before do
          Timecop.travel(itt_start_date)

          post "/api/v0.1/trainees", params: params, headers: { Authorization: token }, as: :json
        end

        it do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body[:errors]).to contain_exactly("Training route has invalid reference data values")
        end
      end
    end
  end

  context "when the trainee record has invalid reference data values" do
    before do
      post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }
    end

    let(:params) { { data: { email: "Doe" } } }

    it "return status code 422 with a meaningful error message" do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["errors"]).to contain_exactly("First names can't be blank", "Last name can't be blank", "Date of birth can't be blank", "Sex can't be blank", "Training route can't be blank", "Itt start date can't be blank", "Itt end date can't be blank", "Course subject one can't be blank", "Study mode can't be blank", "Hesa can't be blank", "Email Enter an email address in the correct format, like name@example.com", "Hesa trainee detail attributes Itt aim can't be blank", "Hesa trainee detail attributes Itt qualification aim can't be blank", "Hesa trainee detail attributes Course year can't be blank", "Hesa trainee detail attributes Course age range can't be blank", "Hesa trainee detail attributes Fund code can't be blank", "Hesa trainee detail attributes Funding method can't be blank")
    end

    context "date of birth is in the future" do
      let(:params) { { data: data.merge({ date_of_birth: "2990-01-01" }) } }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to include({ personal_details: { date_of_birth: ["Enter a date of birth that is in the past, for example 31 3 1980"] } })
      end
    end

    context "when course_age_range is empty" do
      let(:params) { { data: } }
      let(:course_age_range) { "" }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("Hesa trainee detail attributes Course age range can't be blank")
      end
    end

    context "when course_age_range has invalid reference data values" do
      let(:params) { { data: } }
      let(:course_age_range) { "1234" }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("Hesa trainee detail attributes Course age range has invalid reference data values")
      end
    end

    context "when sex is empty" do
      let(:params) { { data: } }
      let(:sex) { "" }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("Sex can't be blank")
      end
    end

    context "when sex has invalid reference data values" do
      let(:params) { { data: } }
      let(:sex) { "3" }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("Sex has invalid reference data values")
      end
    end

    context "when ethnicity has invalid reference data values" do
      let(:ethnicity) { "Irish" }
      let(:params) { { data: data.merge(ethnicity:) } }

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("Ethnicity has invalid reference data values")
      end
    end

    context "when course_subject_one has invalid reference data values" do
      let(:course_subject_one) { "chemistry" }
      let(:params) do
        { data: data.merge({ course_subject_one: }) }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("Course subject one has invalid reference data values")
      end
    end

    context "when course_subject_two has invalid reference data values" do
      let(:course_subject_two) { "child development" }
      let(:params) do
        { data: data.merge({ course_subject_two: }) }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("Course subject two has invalid reference data values")
      end
    end

    context "when course_subject_three has invalid reference data values" do
      let(:course_subject_three) { "classical studies" }
      let(:params) do
        { data: data.merge({ course_subject_three: }) }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("Course subject three has invalid reference data values")
      end
    end

    context "when study_mode has invalid reference data values" do
      let(:study_mode) { 1 }
      let(:params) do
        { data: data.merge({ study_mode: }) }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("Study mode has invalid reference data values")
      end
    end

    context "when nationality has invalid reference data values" do
      let(:nationality) { "british" }
      let(:params) do
        { data: data.merge({ nationality: }) }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("Nationality has invalid reference data values")
      end
    end

    context "when training_initiative has invalid reference data values" do
      let(:training_initiative) { "now_teach" }
      let(:params) do
        { data: data.merge({ training_initiative: }) }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("Training initiative has invalid reference data values")
      end
    end

    context "when funding_method has invalid reference data values" do
      let(:funding_method) { "8c629dd7-bfc3-eb11-bacc-000d3addca7a" }
      let(:params) do
        { data: data.merge({ funding_method: }) }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly("Hesa trainee detail attributes Funding method has invalid reference data values")
      end
    end

    context "when itt_aim has invalid reference data values" do
      let(:itt_aim) { "321" }
      let(:params) do
        { data: data.merge({ itt_aim: }) }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly(
          "Hesa trainee detail attributes Itt aim has invalid reference data values",
        )
      end
    end

    context "when itt_qualification_aim has invalid reference data values" do
      let(:itt_qualification_aim) { "321" }
      let(:params) do
        { data: data.merge({ itt_qualification_aim: }) }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to contain_exactly(
          "Hesa trainee detail attributes Itt qualification aim has invalid reference data values",
        )
      end
    end
  end

  context "when a placement has invalid reference data values" do
    before do
      post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }
    end

    let(:params) { { data: data.merge({ placements_attributes: [{ not_an_attribute: "invalid" }] }) } }

    it "return status code 422 with a meaningful error message" do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["errors"]).to include("Placements attributes Name can't be blank")
    end
  end

  context "when a degree has invalid reference data values" do
    before do
      params[:data][:degrees_attributes].first[:graduation_year] = "3000-01-01"

      post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }
    end

    it "return status code 422 with a meaningful error message" do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["message"]).to include("Validation failed: 2 errors prohibited this trainee from being saved")
      expect(response.parsed_body["errors"]).to include("Degrees graduation year Enter a graduation year that is in the past, for example 2014")
      expect(response.parsed_body["errors"]).to include("Degrees graduation year Enter a valid graduation year")
    end

    context "with invalid degree attributes" do
      before do
        params[:data][:degrees_attributes].first[:uk_degree] = "Bachelor of Arts"

        post "/api/v0.1/trainees", params: params.to_json, headers: { Authorization: token, **json_headers }
      end

      it "return status code 422 with a meaningful error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["message"]).to include("Validation failed: 1 error prohibited this trainee from being saved")
        expect(response.parsed_body["errors"]).to include("Degrees attributes Uk degree has invalid reference data values")
      end
    end
  end
end
