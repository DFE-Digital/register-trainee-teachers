# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dttp::School, type: :model do
  subject { create(:dttp_school) }

  it { is_expected.to have_db_index(:dttp_id) }
end
