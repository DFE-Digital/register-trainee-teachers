# frozen_string_literal: true

require "rails_helper"

describe PagesController, type: :controller do
  describe "GET #data_requirements" do
    it "returns a 200 status code" do
      get :data_requirements
      expect(response).to have_http_status(200)
    end
  end

  describe "start page" do
    context "when not signed in and navigate to start page" do
      it "renders start page" do
        get :start
        expect(response).to render_template("start")
      end
    end
  end

  context "when signed in and navigate to start page" do
    let(:current_user) { build(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
    end

    it "renders home page" do
      get :start
      expect(response).to render_template("home")
    end
  end
end
