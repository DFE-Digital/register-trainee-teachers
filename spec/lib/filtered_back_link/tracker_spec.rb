# frozen_string_literal: true

require "rails_helper"

module FilteredBackLink
  describe Tracker do
    context "empty history" do
      let(:tracker) { described_class.new(session: {}, href: "/trainees") }

      it "return href" do
        expect(tracker.get_path).to eq("/trainees")
      end

      it "saves path" do
        tracker.save_path("/trainees?test=1")
        expect(tracker.get_path).to eq("/trainees?test=1")
      end

      it "overrides path" do
        tracker.save_path("/trainees?test=1")
        expect(tracker.get_path).to eq("/trainees?test=1")

        tracker.save_path("/trainees")
        expect(tracker.get_path).to eq("/trainees")
      end
    end

    context "multiple trackers" do
      let(:tracker1) { described_class.new(session: {}, href: "/trainees") }
      let(:tracker2) { described_class.new(session: {}, href: "/made_up_list") }

      it "return href" do
        expect(tracker1.get_path).to eq("/trainees")
        expect(tracker2.get_path).to eq("/made_up_list")
      end

      it "saves path" do
        tracker1.save_path("/trainees?test=1")
        tracker2.save_path("/made_up_list?test=2")
        expect(tracker1.get_path).to eq("/trainees?test=1")
        expect(tracker2.get_path).to eq("/made_up_list?test=2")
      end

      it "overrides path" do
        tracker1.save_path("/trainees?test=1")
        tracker2.save_path("/made_up_list?test=2")
        expect(tracker1.get_path).to eq("/trainees?test=1")
        expect(tracker2.get_path).to eq("/made_up_list?test=2")

        tracker1.save_path("/trainees")
        tracker2.save_path("/made_up_list")
        expect(tracker1.get_path).to eq("/trainees")
        expect(tracker2.get_path).to eq("/made_up_list")
      end
    end
  end
end
