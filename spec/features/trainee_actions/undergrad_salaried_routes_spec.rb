# frozen_string_literal: true

require "rails_helper"

feature "the Undergraduate (salaried) route group" do
  background { given_i_am_authenticated }

  scenario "lists the degree apprenticeships",
           "feature_routes.early_years_teacher_degree_apprenticeship": true, "feature_routes.teacher_degree_apprenticeship": true do
    visit "/trainees/new"

    within(:xpath, "//fieldset[.//legend[normalize-space()='Undergraduate (salaried)']]") do
      expect(page).to have_field("Teacher degree apprenticeship (salaried)", type: :radio)
      expect(page).to have_field("Early years teacher degree apprenticeship (salaried)", type: :radio)
    end

    within(:xpath, "//fieldset[.//legend[normalize-space()='Other']]") do
      expect(page).not_to have_text("degree apprenticeship")
    end
  end

  scenario "isn't shown when neither route is enabled",
           "feature_routes.early_years_teacher_degree_apprenticeship": false, "feature_routes.teacher_degree_apprenticeship": false do
    visit "/trainees/new"

    expect(page).to have_text("Undergraduate (fee funded)")
    expect(page).not_to have_text("Undergraduate (salaried)")
  end
end
