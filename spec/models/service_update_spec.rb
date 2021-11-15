# frozen_string_literal: true

require "rails_helper"

describe ServiceUpdate do
  before do
    allow(YAML).to receive(:load_file).and_return(
      [
        {
          date: "2021-09-17",
          title: "Most recent item",
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
      expect(ServiceUpdate.all.count).to be(2)

      expect(ServiceUpdate.all[0].title).to eql("Most recent item")
      expect(ServiceUpdate.all[0].content).to eql("Ths is another **Markdown** content.")
      expect(ServiceUpdate.all[0].date).to eql("2021-09-17")

      expect(ServiceUpdate.all[1].title).to eql("Lead and employing schools")
      expect(ServiceUpdate.all[1].content).to eql("Ths is **Markdown** content.")
      expect(ServiceUpdate.all[1].date).to eql("2021-09-01")
    end
  end

  describe "#recent_update" do
    it "returns recent item" do
      su = ServiceUpdate.recent_update

      expect(su.title).to eql("Most recent item")
      expect(su.content).to eql("Ths is another **Markdown** content.")
      expect(su.date).to eql("2021-09-17")
    end
  end
end
