# frozen_string_literal: true

require "rails_helper"

describe ConsistencyCheck do
  context "fields" do
    it "validates presence" do
      expect(subject).to validate_presence_of(:trainee_id)
    end
  end
end
