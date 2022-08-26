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
      expect(response).to render_template("guidance/about_register_trainee_teachers.md")
    end
  end
end
