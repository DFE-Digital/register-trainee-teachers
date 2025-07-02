# frozen_string_literal: true

require "rails_helper"

describe ServiceUpdatesController do
  before do
    allow(YAML).to receive(:load_file).and_return(
      [
        {
          date: "2021-09-17",
          title: "Most recent item",
          content: "This is another **Markdown** content.",
        },
        {
          date: "2021-09-01",
          title: "Lead and employing schools",
          content: "This is **Markdown** content.",
        },
      ],
    )
  end

  describe "GET #index" do
    it "renders service updates" do
      get :index

      expect(response).to have_http_status(:ok)
      expect(assigns(:service_updates).count).to eq(2)
    end
  end

  describe "GET #show" do
    it "renders individual service update" do
      get :show, params: { id: "most-recent-item" }

      expect(response).to have_http_status(:ok)
      expect(assigns(:service_update)).to be_present
      expect(assigns(:service_update).title).to eql("Most recent item")
    end

    it "raises 404 for non-existent service update" do
      expect {
        get :show, params: { id: "non-existent" }
      }.to raise_error(ActionController::RoutingError)
    end
  end
end
