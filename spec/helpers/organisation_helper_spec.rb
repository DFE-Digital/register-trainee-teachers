# frozen_string_literal: true

require "rails_helper"

describe OrganisationHelper do
  include OrganisationHelper

  describe "#hide_draft_records?" do
    describe "lead school user" do
      let(:current_user) { double(UserWithOrganisationContext, lead_school?: true) }

      it "returns true" do
        expect(hide_draft_records?).to be(true)
      end
    end

    describe "non-lead school user" do
      let(:current_user) { double(UserWithOrganisationContext, lead_school?: false) }

      it "returns false" do
        expect(hide_draft_records?).to be(false)
      end
    end
  end
end
