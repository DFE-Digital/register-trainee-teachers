# frozen_string_literal: true

require "rails_helper"

describe ServiceUpdate do
  before do
    allow(YAML).to receive(:load_file).and_return(
      [
        {
          date: "2021-09-21",
          title: "Most recent item",
          content: "This is also another **Markdown** content.",
        },
        {
          date: "2021-09-17",
          title: "Second most recent item",
          content: "This is another **Markdown** content.",
        },
        {
          date: "2021-09-01",
          title: "Lead and employing schools",
          content: "This is **Markdown** content.",
        },
      ],
    )
  end

  describe ".all" do
    it "returns all items sorted by date descending" do
      updates = ServiceUpdate.all

      expect(updates.count).to be(3)
      expect(updates[0].title).to eql("Most recent item")
      expect(updates[0].date).to eql("2021-09-21")
      expect(updates[1].title).to eql("Second most recent item")
      expect(updates[2].title).to eql("Lead and employing schools")
    end
  end

  describe ".find_by_id" do
    it "finds service update by parameterized title" do
      update = ServiceUpdate.find_by_id("most-recent-item")

      expect(update).to be_present
      expect(update.title).to eql("Most recent item")
    end

    it "returns nil for non-existent id" do
      update = ServiceUpdate.find_by_id("non-existent")

      expect(update).to be_nil
    end
  end

  describe "#summary_text" do
    context "when summary field is present" do
      it "returns the summary field" do
        update_data = { summary: "Custom summary", content: "Long content..." }
        service_update = ServiceUpdate.new(update_data)

        expect(service_update.summary_text).to eq("Custom summary")
      end
    end

    context "when summary field is not present" do
      it "generates summary from first paragraph" do
        update_data = { content: "First paragraph\n\nSecond paragraph" }
        service_update = ServiceUpdate.new(update_data)

        expect(service_update.summary_text).to eq("First paragraph")
      end

      it "truncates long first paragraphs" do
        long_content = "A" * 250
        update_data = { content: long_content }
        service_update = ServiceUpdate.new(update_data)

        expect(service_update.summary_text).to eq("#{'A' * 200}...")
      end
    end
  end

  describe ".recent_updates" do
    around do |example|
      Timecop.freeze(2021, 10, 4) do
        example.run
      end
    end

    it "returns items within the last month" do
      updates = ServiceUpdate.recent_updates

      expect(updates.first.title).to eql("Most recent item")
      expect(updates.last.title).to eql("Second most recent item")
      expect(updates.count).to eq(2)
    end
  end
end
