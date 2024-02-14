# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::DegreeAttributes do
  it { is_expected.to validate_inclusion_of(:institution).in_array(DfEReference::DegreesQuery::INSTITUTIONS.all.map(&:name)).allow_nil }
  it { is_expected.to validate_inclusion_of(:subject).in_array(DfEReference::DegreesQuery::SUBJECTS.all.map(&:name)).allow_nil }
  it { is_expected.to validate_inclusion_of(:uk_degree).in_array(DfEReference::DegreesQuery::TYPES.all.map(&:name)).allow_nil }
end
