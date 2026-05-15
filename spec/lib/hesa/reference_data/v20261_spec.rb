# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hesa::ReferenceData::V20261 do
  subject { described_class }

  it { is_expected.to be < Hesa::ReferenceData::V20260 }
end
