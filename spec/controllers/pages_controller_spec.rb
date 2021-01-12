# frozen_string_literal: true

require "rails_helper"

describe PagesController, type: :controller do
  describe "GET #data_requirements" do
    it "returns a 200 status code" do
      get :data_requirements
      expect(response).to have_http_status(200)
    end
  end
end
