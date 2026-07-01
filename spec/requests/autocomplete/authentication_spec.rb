# frozen_string_literal: true

require "rails_helper"

describe "autocomplete authentication" do
  [
    "/autocomplete/users",
    "/autocomplete/providers",
    "/autocomplete/schools",
    "/autocomplete/training-partners",
  ].each do |path|
    it "redirects unauthenticated users to sign in for #{path}" do
      get path

      expect(response).to redirect_to(sign_in_path)
    end
  end
end
