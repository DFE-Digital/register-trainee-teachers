# frozen_string_literal: true

require "rails_helper"

RSpec.describe AllocationSubject, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:subject_specialisms) }
    it { is_expected.to have_many(:bursaries).through(:bursary_subjects) }
  end
end
