# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolDataDownload do
  describe "validations" do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:started_at) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(running: "running", completed: "completed", failed: "failed").with_prefix(true).backed_by_column_of_type(:string) }
  end
end
