# frozen_string_literal: true

require "rails_helper"

RSpec.describe PersonasController, type: :controller do
  describe "#create" do
    let(:response) { post(:create) }
    it "redirects to index page" do
      expect(response).to redirect_to(personas_path)
    end
  end
end
