# frozen_string_literal: true

require "rails_helper"

feature "Funding management — delete draft funding",
        feature_funding_management: true, feature_funding_management_edit: true do
  let(:draft) { AcademicCycle.next || create(:academic_cycle, next_cycle: true) }

  before { given_i_am_authenticated(user: create(:user, :system_admin)) }

  def add_funding(cycle, amount:, subject_name:)
    subject = create(:allocation_subject, name: subject_name)
    method = create(:funding_method,
                    training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad], funding_type: :bursary,
                    amount: amount, academic_cycle: cycle)
    method.allocation_subjects << subject
    [method, subject]
  end

  def visit_draft
    visit "/system-admin/funding-management/requirements?academic_year=#{draft.start_year}"
  end

  scenario "tick boxes are shown and the delete button is hidden until a row is selected" do
    add_funding(draft, amount: 29_000, subject_name: "Chemistry")
    visit_draft

    expect(page).to have_css("#select-all-funding")            # select-all
    expect(page).to have_css(".funding-select")                # per-row tick boxes
    expect(page).not_to have_button("Delete selected funding") # hidden until a row is ticked
    expect(page).to have_button("Delete selected funding", visible: :all)
  end

  scenario "an admin deletes the selected draft funding records" do
    method1, subject1 = add_funding(draft, amount: 29_000, subject_name: "Chemistry")
    method2, subject2 = add_funding(draft, amount: 20_000, subject_name: "Physics")
    visit_draft

    check "select-#{method1.id}-#{subject1.id}"
    check "select-#{method2.id}-#{subject2.id}"
    click_button "Delete selected funding", visible: :all

    expect(page).to have_text("Deleted 2 funding records")
    expect(page).to have_text("No funding is recorded for this academic year.")
    expect(draft.reload.funding_methods.count).to eq(0)
  end

  scenario "delete is not offered once the year is no longer a draft" do
    add_funding(draft, amount: 29_000, subject_name: "Chemistry")
    draft.update!(published: true)
    visit_draft

    expect(page).not_to have_css("#select-all-funding")
    expect(page).not_to have_button("Delete selected funding", visible: :all)
  end
end
