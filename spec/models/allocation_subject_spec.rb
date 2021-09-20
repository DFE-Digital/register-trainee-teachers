# frozen_string_literal: true

require "rails_helper"

RSpec.describe AllocationSubject, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:subject_specialisms) }
    it { is_expected.to have_many(:funding_methods).through(:funding_method_subjects) }
  end
end
