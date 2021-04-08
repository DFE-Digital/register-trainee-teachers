# frozen_string_literal: true

require "rails_helper"

describe ConsistencyCheck do
  context "when adding fields" do
    it "validates presence of trainee_id" do
      expect(subject).to validate_presence_of(:trainee_id)
    end
  end
end
