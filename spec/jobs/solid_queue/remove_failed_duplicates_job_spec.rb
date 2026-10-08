# frozen_string_literal: true

require "rails_helper"

module SolidQueue
  describe RemoveFailedDuplicatesJob do
    before do
      allow(::Rails.env).to receive(:production?).and_return(true)
    end

    it "calls the RemoveFailedDuplicates service in production" do
      expect(RemoveFailedDuplicates).to receive(:call)
      described_class.new.perform
    end
  end
end
