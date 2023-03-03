# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::RowError do
  describe "associations" do
    it { is_expected.to belong_to(:errored_on) }
  end
end
