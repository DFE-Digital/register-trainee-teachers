# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::RecommendationsUploadRow do
  describe "associations" do
    it { is_expected.to belong_to(:recommendations_upload) }
  end

  describe "validations" do
    it { validate_presence_of(:standards_met_at) }
  end
end
