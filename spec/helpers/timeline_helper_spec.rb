# frozen_string_literal: true

require "rails_helper"

describe TimelineHelper do
  include TimelineHelper

  describe "#items_are_single_values?" do
    let(:items) { nil }
    let(:event) do
      TimelineEvent.new(
        title: "Something changed",
        username: Faker::Name.first_name,
        date: Time.zone.today,
        items: items,
      )
    end

    context "when `items` is empty" do
      it "returns false" do
        expect(helper.items_are_single_values?(event)).to be(false)
      end
    end

    context "when `items` is an array of key value pairs" do
      let(:items) { [%w[state awarded]] }

      it "returns false" do
        expect(helper.items_are_single_values?(event)).to be(false)
      end
    end

    context "when `items` is an array of string values" do
      let(:items) { ["state changed to awarded"] }

      it "returns true" do
        expect(helper.items_are_single_values?(event)).to be(true)
      end
    end
  end
end
