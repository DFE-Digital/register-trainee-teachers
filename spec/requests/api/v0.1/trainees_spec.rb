# frozen_string_literal: true

require "rails_helper"

describe "Trainees API" do
  describe "GET /api/v0.1/trainees/:id" do
    let!(:trainee) { create(:trainee, slug: "12345") }

    before do
      create(:provider)
      allow_any_instance_of(Api::TraineesController).to receive(:current_provider).and_return(trainee.provider) # rubocop:disable RSpec/AnyInstance
    end

    it_behaves_like "a register API endpoint", "/api/v0.1/trainees/12345"

    context "when the trainee exists", feature_register_api: true do
      before do
        get "/api/v0.1/trainees/#{trainee.slug}", headers: { Authorization: "Bearer bat" }
      end

      it "returns the trainee" do
        expect(response.parsed_body).to eq(JSON.parse(trainee.to_json))
      end

      it "returns status code 200" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the trainee does not exist", feature_register_api: true do
      before do
        get "/api/v0.1/trainees/nonexistent", headers: { Authorization: "Bearer bat" }
      end

      it "returns status code 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns a not found message" do
        expect(response.parsed_body["error"]).to eq("Trainee not found")
      end
    end
  end

  describe 'POST /api/v0.1/trainees' do
    let(:valid_attributes) do
      {
        trainee: {
          first_names: 'John',
          middle_names: 'James',
          last_name: 'Doe',
          date_of_birth: '1990-01-01',
          sex: 'male',
          email: 'john.doe@example.com',
          trn: '123456',
          training_route: 'assessment_only',
          itt_start_date: '2022-09-01',
          itt_end_date: '2023-07-01',
          diversity_disclosure: 'diversity_disclosed',
          ethnic_group: 'white_ethnic_group',
          ethnic_background: 'Background 1',
          disability_disclosure: 'no_disability',
          course_subject_one: 'Maths',
          course_subject_two: 'Science',
          course_subject_three: 'English',
          study_mode: 'full_time',
          application_choice_id: '123',
          placements_attributes: [{ urn: '123456', name: "Placement" }],
          degrees_attributes: [{ country: 'UK', grade: 'First', subject: 'Computer Science', institution: 'University of Test', graduation_year: '2012', locale_code: 'uk' }]
        }
      }
    end

    before { create(:provider) }

    context 'when the request is valid', feature_register_api: true do
      before { post '/api/v0.1/trainees', params: valid_attributes, headers: { Authorization: "Bearer bat" } }

      it 'creates a trainee' do
        expect(response.parsed_body['first_names']).to eq('John')
      end

      it 'creates associated placements' do
        expect(response.parsed_body['placements'].first['urn']).to eq('123456')
      end

      it 'creates associated degrees' do
        expect(response.parsed_body['degrees'].first['country']).to eq('UK')
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request is invalid', feature_register_api: true do
      before { post '/api/v0.1/trainees', params: { trainee: { last_name: 'Doe' } }, headers: { Authorization: "Bearer bat" } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.parsed_body['errors']).to include("First names can't be blank")
      end
    end
  end
end
