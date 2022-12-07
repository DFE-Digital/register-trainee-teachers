# frozen_string_literal: true

require "rails_helper"

describe ProviderUser do
  subject { create(:provider_user) }

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:user).scoped_to(:provider_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:user) }
  end
end
