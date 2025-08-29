# frozen_string_literal: true

require "rails_helper"

describe GuidanceController do
  before { create(:academic_cycle, previous_cycle: true) }

  describe "#show" do
    it "returns a 200 status code" do
      get :show
      expect(response).to have_http_status(:ok)
    end

    it "renders the application template" do
      get :show
      expect(response).to render_template("application")
    end
  end

  describe "#about_register_trainee_teachers" do
    it "returns a 200 status code" do
      get :about_register_trainee_teachers
      expect(response).to have_http_status(:ok)
    end

    it "renders the correct template and page" do
      get :about_register_trainee_teachers
      expect(response).to render_template("guidance")
      expect(response).to render_template("about_register_trainee_teachers")
    end
  end

  describe "#dates_and_deadlines" do
    it "returns a 200 status code" do
      get :dates_and_deadlines
      expect(response).to have_http_status(:ok)
    end

    it "renders the correct template and page" do
      get :dates_and_deadlines
      expect(response).to render_template("application")
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
      expect(response).to render_template("guidance")
      expect(response).to render_template("manually_registering_trainees")
    end
  end

  describe "#manage_placements" do
    it "returns a 200 status code" do
      get :manage_placements
      expect(response).to have_http_status(:ok)
    end

    it "renders the correct template and page" do
      get :manage_placements
      expect(response).to render_template("application")
    end
  end

  describe "#census_sign_off" do
    it "returns a 200 status code" do
      get :census_sign_off
      expect(response).to have_http_status(:ok)
    end

    it "renders the correct template and page" do
      get :census_sign_off
      expect(response).to render_template("application")
      expect(response).to render_template("census_sign_off")
    end
  end

  describe "#registering_trainees_through_api_or_csv" do
    it "returns a 200 status code" do
      get :registering_trainees_through_api_or_csv
      expect(response).to have_http_status(:ok)
    end

    it "renders the correct template and page" do
      get :registering_trainees_through_api_or_csv
      expect(response).to render_template("guidance")
      expect(response).to render_template("registering_trainees_through_api_or_csv")
    end
  end

  describe "#how_to_extract_trns_from_the_register_service" do
    it "returns a 200 status code" do
      get :how_to_extract_trns_from_the_register_service
      expect(response).to have_http_status(:ok)
    end

    it "renders the correct template and page" do
      get :how_to_extract_trns_from_the_register_service
      expect(response).to render_template("guidance")
      expect(response).to render_template("how_to_extract_trns_from_the_register_service")
    end
  end

  describe "#check_data" do
    it "returns a 200 status code" do
      get :check_data
      expect(response).to have_http_status(:ok)
    end

    it "renders the correct template and page" do
      get :check_data
      expect(response).to render_template("guidance")
      expect(response).to render_template("check_data")
    end
  end

  describe "#performance_profiles" do
    context "when the date is within the performance profiles period" do
      before do
        allow(controller).to receive(:sign_off_period).and_return(:performance_period)
        get :performance_profiles
      end

      it "returns a 200 status code" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the correct template and page" do
        expect(response).to render_template("performance_profiles")
      end
    end

    context "when the date is outside the performance profiles period" do
      before do
        allow(controller).to receive(:sign_off_period).and_return(:outside_period)
        get :performance_profiles
      end

      it "returns a 200 status code" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the correct template and page" do
        expect(response).to render_template("performance_profiles_outside")
      end
    end
  end
end
