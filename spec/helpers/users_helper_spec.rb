# frozen_string_literal: true

require "rails_helper"

describe UsersHelper do
  include UsersHelper

  describe "#lead_school_user?" do
    describe "lead school user" do
      let(:current_user) { double(UserWithOrganisationContext, lead_school?: true) }

      it "returns true" do
        expect(lead_school_user?).to be(true)
      end
    end

    describe "non-lead school user" do
      let(:current_user) { double(UserWithOrganisationContext, lead_school?: false) }

      it "returns false" do
        expect(lead_school_user?).to be(false)
      end
    end
  end
end
