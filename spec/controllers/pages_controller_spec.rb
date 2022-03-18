# frozen_string_literal: true

require "rails_helper"

describe PagesController, type: :controller do
  describe "GET #guidance" do
    it "returns a 200 status code" do
      get :guidance
      expect(response).to have_http_status(:ok)
    end
  end

  describe "start page" do
    context "when not signed in and navigate to start page" do
      it "renders start page" do
        get :start
        expect(session[:requested_path]).to eq "/"
        expect(response).to render_template("start")
      end
    end
  end

  context "when signed in and navigate to start page" do
    let(:current_user) { UserWithOrganisationContext.new(user: create(:user), session: {}) }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
    end

    it "renders home page" do
      get :start
      expect(session[:requested_path]).to eq "/"
      expect(response).to render_template("home")
    end

    context "lead school user" do
      render_views

      before do
        allow(current_user).to receive(:lead_school?).and_return(true)
      end

      it "renders home page" do
        get :start
        expect(response.body).not_to match("Draft trainees")
      end
    end
  end

  describe "GET #start_traineeteacherportal" do
    it "returns a 200 status code" do
      get :start_traineeteacherportal

      expect(response).to have_http_status(:ok)
    end

    it "renders the start_traineeteacherportal page" do
      get :start_traineeteacherportal

      expect(response).to have_rendered("start_traineeteacherportal")
    end
  end
end
