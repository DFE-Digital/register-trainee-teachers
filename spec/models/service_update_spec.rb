# frozen_string_literal: true

require "rails_helper"

describe ServiceUpdate do
  before do
    allow(YAML).to receive(:load_file).and_return(
      [
        {
          date: "2021-09-21",
          title: "Most recent item",
          content: "Ths is also another **Markdown** content.",
        },
        {
          date: "2021-09-17",
          title: "Second most recent item",
          content: "Ths is another **Markdown** content.",
        },
        {
          date: "2021-09-01",
          title: "Lead and employing schools",
          content: "Ths is **Markdown** content.",
        },
      ],
    )
  end

  describe "#all" do
    it "returns all items" do
      expect(ServiceUpdate.all.count).to be(3)

      expect(ServiceUpdate.all[0].title).to eql("Most recent item")
      expect(ServiceUpdate.all[0].content).to eql("Ths is also another **Markdown** content.")
      expect(ServiceUpdate.all[0].date).to eql("2021-09-21")

      expect(ServiceUpdate.all[1].title).to eql("Second most recent item")
      expect(ServiceUpdate.all[1].content).to eql("Ths is another **Markdown** content.")
      expect(ServiceUpdate.all[1].date).to eql("2021-09-17")

      expect(ServiceUpdate.all[2].title).to eql("Lead and employing schools")
      expect(ServiceUpdate.all[2].content).to eql("Ths is **Markdown** content.")
      expect(ServiceUpdate.all[2].date).to eql("2021-09-01")
    end
  end

  describe "#recent_update" do
    around do |example|
      Timecop.freeze(2021, 10, 4) do
        example.run
      end
    end

    it "returns all item within the last month" do
      su = ServiceUpdate.recent_updates

      expect(su.first.title).to eql("Most recent item")
      expect(su.first.content).to eql("Ths is also another **Markdown** content.")
      expect(su.first.date).to eql("2021-09-21")
      expect(su.last.title).to eql("Second most recent item")
      expect(su.last.content).to eql("Ths is another **Markdown** content.")
      expect(su.last.date).to eql("2021-09-17")
    end
  end
end
