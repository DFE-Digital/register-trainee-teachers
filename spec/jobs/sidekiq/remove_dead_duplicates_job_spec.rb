# frozen_string_literal: true

require "rails_helper"

module Sidekiq
  describe RemoveDeadDuplicatesJob do
    it "calls the RemoveDeadDuplicates service" do
      expect(RemoveDeadDuplicates).to receive(:call)
      described_class.new.perform
    end
  end
end
