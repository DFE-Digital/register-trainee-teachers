# frozen_string_literal: true

require "rails_helper"

describe RunConsistencyChecksJob do
  include ActiveJob::TestHelper

  let(:consistency_check) { create(:consistency_check) }

  before do
    consistency_check
  end

  it "it run all consistency check jobs" do
    ConsistencyCheck.all.each do |consistency_check|
      expect(Dttp::CheckConsistencyJob).not_to have_been_enqueued.with(consistency_check.id)
    end
  end
end
