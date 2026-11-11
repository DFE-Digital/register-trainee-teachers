# frozen_string_literal: true

require "rails_helper"

feature "level 5 declaration" do
  background { given_i_am_authenticated }

  scenario "an EYTDA trainee declares whether they hold a level 5 qualification" do
    given_a_trainee_exists(:early_years_teacher_degree_apprenticeship)

    when_i_visit_the_review_draft_page
    then_i_see_the_task_after_diversity_information

    when_i_click_on("Level 5 declaration")
    then_i_see_the_question

    when_i_click_on("Continue")
    then_i_see_the_error

    when_i_choose_yes_and_continue
    then_i_see_the_confirm_page_with("Yes", duration: "2 years")

    when_i_click_on("Change")
    and_i_choose_no_and_continue
    then_i_see_the_confirm_page_with("No", duration: "3 years")

    when_i_confirm_the_section
    then_the_task_is("Completed")
    and_the_trainee_does_not_hold_a_level_five_qualification
  end

  scenario "other routes don't have the section" do
    given_a_trainee_exists(:provider_led_postgrad)

    when_i_visit_the_review_draft_page
    then_i_do_not_see_the_task
  end

  scenario "check record lists the section until it's complete" do
    given_a_trainee_exists(:early_years_teacher_degree_apprenticeship)

    visit "/trainees/#{trainee.slug}/check-details"
    expect(page).to have_text("Level 5 declaration not started")
  end

private

  def when_i_visit_the_review_draft_page
    review_draft_page.load(id: trainee.slug)
  end

  def then_i_see_the_task_after_diversity_information
    expect(page).to have_css("h2", text: "Personal details and education")
    tasks = page.all(".app-task-list__item").map { |item| item.find(".app-task-list__key").text.strip }
    expect(tasks.index("Level 5 declaration")).to eq(tasks.index("Diversity information") + 1)
    within(".level-five-declaration-details") { expect(page).to have_css(".govuk-tag", text: "Incomplete") }
  end

  def then_i_do_not_see_the_task
    expect(page).not_to have_text("Level 5 declaration")
  end

  def when_i_click_on(text)
    click_on(text)
  end
  alias_method :and_i_click_on, :when_i_click_on

  def then_i_see_the_question
    expect(page).to have_css("h1", text: "Level 5 declaration")
    expect(page).to have_text("Their answer sets the course duration")
    expect(page).to have_text("with a level 5 qualification, 2 years")
    expect(page).to have_text("without a level 5 qualification, 3 years")
    expect(page).to have_text("Level 5 qualifications include foundation degrees")
    expect(page).to have_css("legend", text: "Does the trainee hold a level 5 qualification?")
    expect(page).to have_text("The course duration will be set at 2 years")
    expect(page).to have_text("The course duration will be set at 3 years")
  end

  def then_i_see_the_error
    expect(page).to have_css(".govuk-error-summary", text: "Select yes if the trainee holds a level 5 qualification")
  end

  def when_i_choose_yes_and_continue
    choose("Yes")
    click_on("Continue")
  end

  def and_i_choose_no_and_continue
    choose("No")
    click_on("Continue")
  end

  def then_i_see_the_confirm_page_with(answer, duration:)
    expect(page).to have_css("h1", text: "Confirm level 5 declaration")
    within(".app-summary-card") do
      expect(page).to have_text("Level 5 qualification")
      expect(page).to have_text(answer)
      expect(page).to have_css(".govuk-summary-list__row", text: /Course duration\s*#{duration}/)
    end
  end

  def when_i_confirm_the_section
    check("I have completed this section")
    click_on("Continue")
  end

  def then_the_task_is(status)
    within(".level-five-declaration-details") { expect(page).to have_css(".govuk-tag", text: status) }
  end

  def and_the_trainee_does_not_hold_a_level_five_qualification
    expect(trainee.reload.level_five_qualification).to be(false)
  end
end
