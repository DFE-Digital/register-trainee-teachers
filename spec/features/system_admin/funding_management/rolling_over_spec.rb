# frozen_string_literal: true

require "rails_helper"

feature "Funding management — roll over funding",
        feature_funding_management: true, feature_funding_management_edit: true do
  let(:source) { AcademicCycle.current || create(:academic_cycle, :current) }
  let(:target) { AcademicCycle.next || create(:academic_cycle, next_cycle: true) }

  before do
    given_i_am_authenticated(user: create(:user, :system_admin))
    chemistry = create(:allocation_subject, name: "Chemistry")
    create(:funding_method,
           training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad], funding_type: :bursary,
           amount: 29_000, academic_cycle: source).tap { |m| m.allocation_subjects << chemistry }
    target # ensure the empty future draft year exists
  end

  scenario "rolls the previous year's funding into an empty draft year" do
    visit "/system-admin/funding-management/requirements?academic_year=#{target.start_year}"
    expect(page).to have_text("No funding is recorded for this academic year.")
    expect(page).to have_link("Roll over funding from #{source.label}")

    click_on "Roll over funding from #{source.label}"

    expect(page).to have_text("copies 1 funding record")
    expect(page).to have_text(source.label)
    click_on "Roll over funding"

    expect(page).to have_text("Rolled over 1 funding record from #{source.label} into #{target.label}")
    expect(page).to have_text("Provider led postgraduate")
    expect(page).to have_text("£29,000")
    expect(target.reload.funding_methods.count).to eq(1)
    # once populated it is no longer offered
    expect(page).not_to have_link("Roll over funding from #{source.label}")
  end

  scenario "roll over is not offered once the year already has funding" do
    create(:funding_method, academic_cycle: target)
    visit "/system-admin/funding-management/requirements?academic_year=#{target.start_year}"
    expect(page).to have_css("h1")
    expect(page).not_to have_link(/Roll over funding/)
  end
end
