# frozen_string_literal: true

require "rails_helper"

describe ConsistencyCheck do
  context "fields" do
    it "validates presence" do
      expect(subject).to validate_presence_of(:trainee_id)
      expect(subject).to validate_presence_of(:contact_last_updated_at)
    end

    it { is_expected.to validate_uniqueness_of(:contact_last_updated_at).scoped_to(:trainee_id) }
  end
end
