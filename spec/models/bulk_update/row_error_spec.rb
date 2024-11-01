# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::RowError do
  describe "associations" do
    it { is_expected.to belong_to(:errored_on) }
  end

  it do
    is_expected.to define_enum_for(
      :error_type
    ).with_values(
      duplicate: "duplicate",
      validation: "validation",
    ).backed_by_column_of_type(:string)
  end
end
