# frozen_string_literal: true

require "rails_helper"

describe GuidanceController, type: :controller do
  describe "#show" do
    it "returns a 200 status code" do
      get :show
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#about_register_trainee_teachers" do
    it "returns a 200 status code" do
      get :about_register_trainee_teachers
      expect(response).to have_http_status(:ok)
    end

    it "renders the correct template and page" do
      get :about_register_trainee_teachers
      expect(response).to render_template("guidance_markdown")
      expect(response).to render_template("about_register_trainee_teachers.md")
    end
  end

  describe "#dates_and_deadlines" do
    it "returns a 200 status code" do
      get :dates_and_deadlines
      expect(response).to have_http_status(:ok)
    end

    it "renders the correct page" do
      get :dates_and_deadlines
      expect(response).to render_template("dates_and_deadlines")
    end
  end

  describe "#manually_registering_trainees" do
    it "returns a 200 status code" do
      get :manually_registering_trainees
      expect(response).to have_http_status(:ok)
    end

    it "renders the correct template and page" do
      get :manually_registering_trainees
      expect(response).to render_template("guidance_markdown")
      expect(response).to render_template("manually_registering_trainees")
    end
  end

  describe "#registering_trainees_through_hesa" do
    it "returns a 200 status code" do
      get :registering_trainees_through_hesa
      expect(response).to have_http_status(:ok)
    end

    it "renders the correct template and page" do
      get :registering_trainees_through_hesa
      expect(response).to render_template("guidance_markdown")
      expect(response).to render_template("registering_trainees_through_hesa")
    end
  end
end
