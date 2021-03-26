# frozen_string_literal: true

require 'rails_helper'

describe RunConsistencyChecksJob do
  include ActiveJob::TestHelper

  let(:consistency_check) { create(:consistency_check) }

  before do
    allow(ConsistencyCheck).to receive(:all) { [consistency_check] }
  end

  context "something" do
    pending "it does something" do
      
    end
  end
end
