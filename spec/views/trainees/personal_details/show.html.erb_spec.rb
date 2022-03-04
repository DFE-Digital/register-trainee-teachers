# frozen_string_literal: true

require "rails_helper"

describe "trainees/personal_details/show.html.erb" do
  let(:lead_school_user?) { false }
  let(:trainee) { create(:trainee) }

  before do
    assign(:trainee, trainee)
    without_partial_double_verification do
      allow(view).to receive(:trainee_editable?).and_return(true)
      allow(view).to receive(:lead_school_user?).and_return(lead_school_user?)
    end
    render
  end

  context "with a trainee with no degree" do
    it "renders the incomplete section component" do
      expect(rendered).to have_text("Add degree details")
    end
  end

  context "with a trainee with a degree" do
    let(:trainee) { create(:trainee, :in_progress) }

    it "renders the confirmation component" do
      expect(rendered).to have_text("Add another degree")
    end
  end

  context "minimal mode" do
    let(:lead_school_user?) { true }

    it "doesn't display gender or nationality" do
      expect(rendered).not_to have_text("Gender")
      expect(rendered).not_to have_text("Nationality")
    end

    it "doesn't display diversity information" do
      expect(rendered).not_to have_text("Diversity")
    end
  end
end
