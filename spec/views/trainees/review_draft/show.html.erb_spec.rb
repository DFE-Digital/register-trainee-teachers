# frozen_string_literal: true

require "rails_helper"

describe "trainees/review_draft/show.html.erb" do
  before do
    assign(:trainee, trainee)
    render
  end

  describe "trainees/review_draft/show.html.erb", "feature_routes.provider_led_postgrad": true do
    before do
      assign(:trainee, trainee)
      render
    end

    context "with an Assessment only trainee" do
      let(:trainee) { create(:trainee) }

      it "does not render the placement details component" do
        expect(rendered).not_to have_text("Placement details")
      end
    end

    context "with a Provider-led (postgrad) trainee" do
      let(:trainee) { create(:trainee, :provider_led_postgrad) }

      xit "renders the placement details component" do
        expect(rendered).to have_text("Placement details")
      end
    end
  end

  describe "trainees/review_draft/show.html.erb", "feature_routes.provider_led_postgrad": true

  context "with a named Apply draft trainee" do
    let(:trainee) { create(:trainee, :with_apply_application) }
    let(:trainee_name) { "#{trainee.first_names} #{trainee.middle_names} #{trainee.last_name}" }

    it "renders Apply draft text" do
      expect(rendered).to have_text("Apply draft")
      expect(rendered).to have_text(trainee_name)
    end
  end

  context "with an unnamed Apply draft trainee" do
    let(:trainee) { create(:trainee, :with_apply_application, first_names: nil, middle_names: nil, last_name: nil) }

    it "renders Apply draft text" do
      expect(rendered).to have_text("Register a trainee")
    end
  end

  context "with a named normal draft trainee" do
    let(:trainee) { create(:trainee, :draft) }
    let(:trainee_name) { "#{trainee.first_names} #{trainee.middle_names} #{trainee.last_name}" }

    it "renders draft record text" do
      expect(rendered).to have_text("Draft record")
      expect(rendered).to have_text(trainee_name)
    end
  end

  context "with an unnamed normal draft trainee" do
    let(:trainee) { create(:trainee, first_names: nil, middle_names: nil, last_name: nil) }

    it "renders draft record text" do
      expect(rendered).to have_text("Add a trainee")
    end
  end
end
