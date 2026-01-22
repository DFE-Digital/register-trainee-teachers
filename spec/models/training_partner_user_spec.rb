# frozen_string_literal: true

require "rails_helper"

RSpec.describe TrainingPartnerUser do
  describe "associations" do
    it { is_expected.to belong_to(:training_partner) }
    it { is_expected.to belong_to(:user) }
  end
end
