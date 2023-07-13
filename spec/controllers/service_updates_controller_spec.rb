# frozen_string_literal: true

require "rails_helper"

describe ServiceUpdatesController do
  before do
    allow(YAML).to receive(:load_file).and_return(
      [
        {
          date: "2021-09-17",
          title: "Most recent item",
          content: "Ths is another **Markdown** content.",
        },
        {
          date: "2021-09-01",
          title: "Lead and employing schools",
          content: "Ths is **Markdown** content.",
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
end
