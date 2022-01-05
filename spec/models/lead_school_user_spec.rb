# frozen_string_literal: true

require "rails_helper"

describe LeadSchoolUser do
  describe "associations" do
    it { is_expected.to belong_to(:lead_school) }
    it { is_expected.to belong_to(:user) }
  end
end
