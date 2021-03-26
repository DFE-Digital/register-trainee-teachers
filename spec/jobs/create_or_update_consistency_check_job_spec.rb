# frozen_string_literal: true

require 'rails_helper'

describe CreateOrUpdateConsistencyCheckJob do
  include ActiveJob::TestHelper

  let(:contact) { create(:contact) }
  let(:placement_assignment) { create(:placement_assignment) }

  before do
    allow(Dttp::Contacts::Fetch).to receive(:call) { contact }
    allow(Dttp::PlacementAssignments::Fetch).to receive(:call) { placement_assignment }
  end

  context "consistency check doesnt exist with trainee" do
    pending "it creates a new consistency check object with relative fields" do
      
    end
  end

  context "consistency check exists with trainee" do
    pending "it will upate an existing consistency check" do
      
    end
  end
end
