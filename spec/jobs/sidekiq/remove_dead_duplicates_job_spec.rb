# frozen_string_literal: true

require "rails_helper"

module Sidekiq
  describe RemoveDeadDuplicatesJob do
    before do
      allow(::Rails.env).to receive(:production?).and_return(true)
    end

    it "calls the RemoveDeadDuplicates service in production" do
      expect(RemoveDeadDuplicates).to receive(:call)
      described_class.new.perform
    end
  end
end
