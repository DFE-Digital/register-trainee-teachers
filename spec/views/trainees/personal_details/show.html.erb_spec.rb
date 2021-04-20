# frozen_string_literal: true

require "rails_helper"

describe "trainees/personal_details/show.html.erb" do
  before do
    assign(:trainee, trainee)
    render
  end

  context "with a trainee with no degree" do
    let(:trainee) { create(:trainee) }

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
end
