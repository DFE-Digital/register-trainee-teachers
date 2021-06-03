# frozen_string_literal: true

require "rails_helper"

RSpec.describe Badges::View do
  include Rails.application.routes.url_helpers

  alias_method :component, :page

  let(:current_user) { create(:user, system_admin: true) }

  before do
    trainees
    render_inline(described_class.new(Trainee.all))
  end

  context "No trainees have received or are recommended for qualifications" do
    let(:trainees) { [create(:trainee, state: :draft)] }

    it "renders neutral text for those qualification states" do
      expect(component).to have_text("Qualification recommended")
      expect(component).to have_text("Qualification received")
    end
  end

  context "There are trainees recommended or have received eyts" do
    let(:trainees) { [create(:trainee, state: :awarded, training_route: :early_years_undergrad)] }

    it "renders eyts text or those qualification states" do
      expect(component).to have_text("EYTS recommended")
      expect(component).to have_text("EYTS received")
    end
  end

  context "There are trainees recommended or have received qts" do
    let(:trainees) { [create(:trainee, state: :awarded, training_route: :assessment_only)] }

    it "renders qts text or those qualification states" do
      expect(component).to have_text("QTS recommended")
      expect(component).to have_text("QTS received")
    end
  end

  context "There are trainees recommended or have received qts and eyts" do
    let(:trainees) do
      [
        create(:trainee, state: :awarded, training_route: :assessment_only),
        create(:trainee, state: :awarded, training_route: :early_years_undergrad),
      ]
    end

    it "renders neutral text or those qualification states" do
      expect(component).to have_text("Qualification recommended")
      expect(component).to have_text("Qualification received")
    end
  end
end
