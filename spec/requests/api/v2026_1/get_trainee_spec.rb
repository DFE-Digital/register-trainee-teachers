# frozen_string_literal: true

require "rails_helper"

describe "`GET /api/v2026.1/trainees/:id` endpoint" do
  let!(:auth_token) { create(:authentication_token) }
  let!(:token) { auth_token.token }
  let!(:trainee) { create(:trainee, :with_hesa_trainee_detail, slug: "12345", provider: auth_token.provider) }

  it_behaves_like "a register API endpoint", "/api/v2026.1/trainees/12345"

  context "when the trainee exists" do
    before do
      get(
        "/api/v2026.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
      )
    end

    it "returns the trainee" do
      parsed_trainee = JSON.parse(Api::GetVersionedItem.for_serializer(model: :trainee, version: "v2026.1").new(trainee).as_hash.to_json)
      expect(response.parsed_body).to eq(parsed_trainee)
    end

    it "returns status 200" do
      expect(response).to have_http_status(:ok)
    end
  end

  context "when the trainee has a hesa_trainee_detail" do
    let!(:trainee) do
      create(:trainee, :with_hesa_trainee_detail, :with_tiered_bursary, slug: "12345", provider: auth_token.provider)
    end

    before do
      get(
        "/api/v2026.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
      )
    end

    context "with a funding_method" do
      it "returns the stored funding_method" do
        expect(response.parsed_body["funding_method"]).to eq(trainee.hesa_trainee_detail.funding_method)
      end
    end

    context "without a funding_method" do
      let!(:trainee) do
        create(:trainee, :with_hesa_trainee_detail, :with_tiered_bursary, slug: "12345", provider: auth_token.provider).tap do |trainee|
          trainee.hesa_trainee_detail.update!(funding_method: nil)
        end
      end

      it "returns the funding_method mapped from the trainee funding attributes" do
        expect(response.parsed_body["funding_method"]).to eq(Hesa::CodeSets::BursaryLevels::TIER_ONE)
      end
    end

    context "with a course_study_mode" do
      it "returns the stored course_study_mode as study_mode" do
        expect(response.parsed_body["study_mode"]).to eq(trainee.hesa_trainee_detail.course_study_mode)
      end
    end

    context "without a course_study_mode" do
      let!(:trainee) do
        create(:trainee, :with_hesa_trainee_detail, study_mode: COURSE_STUDY_MODES[:part_time], slug: "12345", provider: auth_token.provider).tap do |trainee|
          trainee.hesa_trainee_detail.update!(course_study_mode: nil)
        end
      end

      it "returns the canonical HESA code mapped from the trainee study mode" do
        expect(response.parsed_body["study_mode"]).to eq("31")
      end
    end
  end

  context "when the trainee has no hesa_trainee_detail" do
    let!(:trainee) do
      create(:trainee, :with_tiered_bursary, study_mode: COURSE_STUDY_MODES[:full_time], slug: "12345", provider: auth_token.provider)
    end

    before do
      get(
        "/api/v2026.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
      )
    end

    it "returns the funding_method mapped from the trainee funding attributes" do
      expect(response.parsed_body["funding_method"]).to eq(Hesa::CodeSets::BursaryLevels::TIER_ONE)
    end

    it "returns the canonical HESA code mapped from the trainee study mode" do
      expect(response.parsed_body["study_mode"]).to eq("01")
    end
  end

  context "when the trainee has a stored course_age_range" do
    let!(:trainee) do
      create(:trainee, :with_hesa_trainee_detail, slug: "12345", provider: auth_token.provider)
    end

    before do
      get(
        "/api/v2026.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
      )
    end

    it "returns the stored course_age_range" do
      expect(response.parsed_body["course_age_range"]).to eq(trainee.hesa_trainee_detail.course_age_range)
    end
  end

  context "when the hesa_trainee_detail has no course_age_range" do
    let!(:trainee) do
      create(:trainee, :with_hesa_trainee_detail, course_min_age: 11, course_max_age: 16, slug: "12345", provider: auth_token.provider).tap do |trainee|
        trainee.hesa_trainee_detail.update!(course_age_range: nil)
      end
    end

    before do
      get(
        "/api/v2026.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
      )
    end

    it "returns the course_age_range mapped from the trainee's range" do
      expect(response.parsed_body["course_age_range"]).to eq("13918")
    end
  end

  context "when the trainee has no hesa_trainee_detail and is missing a course_age_range" do
    let!(:trainee) do
      create(:trainee, course_min_age: 11, course_max_age: 16, slug: "12345", provider: auth_token.provider)
    end

    before do
      get(
        "/api/v2026.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
      )
    end

    it "returns the course_age_range mapped from the trainee's range" do
      expect(response.parsed_body["course_age_range"]).to eq("13918")
    end
  end

  context "when the trainee has stored disabilities" do
    let!(:trainee) do
      create(:trainee, :with_hesa_trainee_detail, :disabled_with_disabilities_disclosed, slug: "12345", provider: auth_token.provider)
    end

    before do
      get(
        "/api/v2026.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
      )
    end

    it "returns the stored disabilities" do
      expect(response.parsed_body["disability1"]).to eq(trainee.hesa_trainee_detail.hesa_disabilities["disability1"])
    end
  end

  context "when the hesa_trainee_detail has no stored disabilities" do
    let!(:trainee) do
      create(:trainee, :with_hesa_trainee_detail, :disabled_with_disabilities_disclosed, slug: "12345", provider: auth_token.provider).tap do |trainee|
        trainee.hesa_trainee_detail.update!(hesa_disabilities: {})
      end
    end

    before do
      get(
        "/api/v2026.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
      )
    end

    it "returns the disabilities mapped from the trainee's disabilities" do
      expect(response.parsed_body["disability1"]).to eq("55")
    end
  end

  context "when the trainee has no hesa_trainee_detail and has disabilities" do
    let!(:trainee) do
      create(:trainee, :disabled_with_disabilities_disclosed, slug: "12345", provider: auth_token.provider)
    end

    before do
      get(
        "/api/v2026.1/trainees/#{trainee.slug}",
        headers: { Authorization: "Bearer #{token}" },
      )
    end

    it "returns the disabilities mapped from the trainee's disabilities" do
      expect(response.parsed_body["disability1"]).to eq("55")
    end
  end

  context "when the trainee does not exist" do
    before do
      get(
        "/api/v2026.1/trainees/nonexistent",
        headers: { Authorization: "Bearer #{token}" },
      )
    end

    it "returns status 404" do
      expect(response).to have_http_status(:not_found)
    end

    it "returns a not found message" do
      expect(response.parsed_body[:errors]).to contain_exactly({ error: "NotFound", message: "Trainee(s) not found" })
    end
  end
end
