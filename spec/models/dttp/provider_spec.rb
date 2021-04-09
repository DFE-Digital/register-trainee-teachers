# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dttp::Provider, type: :model do
  subject { create(:dttp_provider) }

  it { is_expected.to have_db_index(:dttp_id) }
end
