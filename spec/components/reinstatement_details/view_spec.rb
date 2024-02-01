# frozen_string_literal: true

require "rails_helper"

describe ReinstatementDetails::View do
  include SummaryHelper

  let(:trainee) { build(:trainee, :deferred, id: 1) }
  let(:reinstatement_form) { OpenStruct.new(trainee: trainee, date: 1.month.ago) }
  let(:itt_end_date_form) { OpenStruct.new(trainee: trainee, itt_end_date: 1.week.ago) }

  before do
    render_inline(described_class.new(reinstatement_form:, itt_end_date_form:))
  end

  it "renders the date the trainee will be reinstated" do
    expect(rendered_content).to have_text(date_for_summary_view(reinstatement_form.date))
  end

  it "renders the change link for the reinstated date" do
    expect(rendered_content).to have_link("Change", href: "/trainees/#{trainee.slug}/reinstate")
  end

  it "renders the expected end date" do
    expect(rendered_content).to have_text(date_for_summary_view(itt_end_date_form.itt_end_date))
  end

  it "renders the change link for the expected end date" do
    expect(rendered_content).to have_link("Change", href: "/trainees/#{trainee.slug}/reinstate/update-end-date")
  end

  it "does not renders the 'Trainee returned before their ITT started'" do
    expect(rendered_content).not_to have_text("Trainee returned before their ITT started")
  end

  context "deferred before starting course" do
    let(:reinstatement_form) { OpenStruct.new(trainee: trainee, date: nil) }

    it "renders the 'Trainee returned before their ITT started'" do
      expect(rendered_content).to have_text("Trainee returned before their ITT started")
    end

    it "does not renders the expected end date row" do
      expect(rendered_content).not_to have_css(".expected-end-date")
    end
  end
end
