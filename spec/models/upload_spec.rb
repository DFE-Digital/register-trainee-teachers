# frozen_string_literal: true

require "rails_helper"

RSpec.describe Upload do
  context "scopes" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_one_attached(:file) }
  end

  context "validations" do
    it { is_expected.to validate_presence_of(:file) }
    it { is_expected.to validate_presence_of(:name) }
  end
end
