# frozen_string_literal: true

require "rails_helper"

RSpec.describe Activity, type: :model do
  let(:current_user) { create(:user) }

  context "fields" do
    it "validates" do
      expect(subject).to validate_presence_of(:controller_name)
      expect(subject).to validate_presence_of(:action_name)
    end
  end

  describe "#track" do
    it "tracks activity" do
      Activity.track(
        user: current_user,
        controller_name: "test",
        action_name: "download",
        metadata: { test1: 1, test2: "blah" },
      )

      activity = Activity.last
      expect(activity.controller_name).to eql("test")
      expect(activity.action_name).to eql("download")
      expect(activity.metadata).to eql({ "test1" => 1, "test2" => "blah" })
    end
  end
end
