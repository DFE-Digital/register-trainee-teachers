# frozen_string_literal: true

require "rails_helper"

describe "authentication", type: :request do
  context "attempting to visit a restricted page" do
    context "without been authenticated" do
      it "redirects back to the sign in page" do
        get trainees_path
        expect(response).to redirect_to(sign_in_path)
      end
    end
  end
end
