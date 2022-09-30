# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe User do
    subject { build(:dttp_user) }

    it { is_expected.to be_valid }
  end
end
