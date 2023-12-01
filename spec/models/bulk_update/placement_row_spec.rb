# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::PlacementRow do
  describe "associations" do
    it { is_expected.to belong_to(:bulk_update_placement) }
    it { is_expected.to belong_to(:school).optional }
    it { is_expected.to have_many(:row_errors) }
  end
end
