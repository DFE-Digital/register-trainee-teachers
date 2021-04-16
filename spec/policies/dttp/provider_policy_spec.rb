# frozen_string_literal: true

require "rails_helper"

describe Dttp::ProviderPolicy do
  let(:system_admin_user) { build(:user, :system_admin) }
  let(:other_user) { create(:user) }

  subject { described_class }

  permissions :index?, :show?, :new?, :create? do
    it { is_expected.to permit(system_admin_user) }
    it { is_expected.not_to permit(other_user) }
  end
end
