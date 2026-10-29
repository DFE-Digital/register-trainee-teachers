# frozen_string_literal: true

require "rails_helper"

feature "placement requirements text" do
  background { given_i_am_authenticated }

  scenario "an EYTDA trainee sees what early years teacher degree apprentices must do" do
    given_a_trainee_exists(:early_years_teacher_degree_apprenticeship)

    visit "/trainees/#{trainee.slug}/placements/details/edit"
    expect(page).to have_text("Early years teacher degree apprentices must do 3 placements before they can be awarded EYTS.")
    expect(page).to have_text("a placement in an alternative setting, such as a family hub or Children’s Centre")
    expect(page).to have_text("a placement in a supplementary setting, if they cannot teach children aged 0 to 5 in the setting where they work")
    expect(page).not_to have_text("at least 2 schools")
  end

  scenario "other routes keep the schools text" do
    given_a_trainee_exists(:provider_led_postgrad)

    visit "/trainees/#{trainee.slug}/placements/details/edit"
    expect(page).to have_text("You need to add the details of at least 2 schools.")
    expect(page).not_to have_text("Early years teacher degree apprentices")
  end
end
