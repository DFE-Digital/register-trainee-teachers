# frozen_string_literal: true

require "rails_helper"

RSpec.describe Badges::View do
  include Rails.application.routes.url_helpers

  let(:current_user) { create(:user, system_admin: true) }

  let(:counts) do
    {
      draft: 10,
      submitted_for_trn: 20,
      trn_received: 150,
      deferred: 10,
      withdrawn: 0,
    }.with_indifferent_access
  end

  before do
    render_inline(described_class.new(counts))
  end

  context "No trainees have received or are recommended for qualifications" do
    let(:counts) do
      super().merge(
        awarded: 0,
        recommended_for_award: 0,
      )
    end

    it "renders neutral text for those qualification states" do
      expect(rendered_component).to include("Qualification recommended")
      expect(rendered_component).to include("Qualification received")
    end
  end

  context "There are trainees recommended or have received eyts" do
    let(:counts) do
      super().merge(
        eyts_recommended: 0,
        eyts_received: 0,
      )
    end

    it "renders eyts text or those qualification states" do
      expect(rendered_component).to include("EYTS recommended")
      expect(rendered_component).to include("EYTS received")
    end
  end

  context "There are trainees recommended or have received qts" do
    let(:counts) do
      super().merge(
        qts_recommended: 0,
        qts_received: 0,
      )
    end

    it "renders qts text or those qualification states" do
      expect(rendered_component).to include("QTS recommended")
      expect(rendered_component).to include("QTS received")
    end
  end
end
