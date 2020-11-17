# frozen_string_literal: true

require "rails_helper"

describe Nationalisation do
  describe "associations" do
    it { is_expected.to belong_to(:trainee) }
    it { is_expected.to belong_to(:nationality) }
  end
end
