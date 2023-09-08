# frozen_string_literal: true

require "rails_helper"

describe PagesController do |_render_views|
  describe "GET #dttp_replaced" do
    it "renders the dttp_replaced page" do
      get :dttp_replaced
      expect(response).to have_http_status(:ok)
      expect(response).to render_template("application")
      expect(response).to have_rendered("dttp_replaced")
    end
  end

  %i[accessibility privacy_notice data_sharing_agreement].each do |page|
    describe "##{page}" do
      it "renders the correct template and page" do
        get page
        expect(response).to have_http_status(:ok)
        expect(response).to render_template("pages")
        expect(response).to render_template(page)
      end
    end
  end
end
