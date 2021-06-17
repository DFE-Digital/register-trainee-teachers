# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubjectSpecialism, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:allocation_subject) }
  end
end
