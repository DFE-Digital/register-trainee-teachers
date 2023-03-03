require 'rails_helper'

RSpec.describe BulkUpdate::RowError, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:errored_on) }
  end
end
