# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubjectSpecialism, type: :model do
  subject { create(:subject_specialism) }

  describe "associations" do
    it { is_expected.to belong_to(:allocation_subject) }
  end

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end
