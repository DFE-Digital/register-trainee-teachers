# frozen_string_literal: true

require "rails_helper"

describe Hesa::TraineeDetail do
  subject { build(:hesa_trainee_detail) }

  it { is_expected.to be_valid }
end
