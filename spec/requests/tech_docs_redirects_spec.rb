# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Tech Docs redirects" do
  %w[api-docs csv-docs reference-data].each do |path|
    describe "/#{path}/" do
      context "when the path is '/#{path}'" do
        before do
          get "/#{path}"
        end

        it "redirects to '/#{path}/'" do
          expect(response).to have_http_status(:moved_permanently)
          expect(response).to redirect_to("/#{path}/")
        end
      end

      context "when the path is '/#{path}/'" do
        before do
          get "/#{path}/"
        end

        it "does not redirect" do
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
