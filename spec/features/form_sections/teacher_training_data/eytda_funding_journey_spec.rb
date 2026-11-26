# frozen_string_literal: true

require "rails_helper"

feature "early years teacher degree apprenticeship funding journey" do
  background { given_i_am_authenticated }

  context "with the funding eligibility step", feature_funding_eligibility_step: true do
    before { AcademicCycle.find_each { |cycle| cycle.update!(published: true) } }

    scenario "eligibility goes straight to the ESG, without a training initiative" do
      given_an_eytda_trainee_with_course_details
      and_an_esg_exists

      when_i_visit_the_funding_eligibility_page
      then_i_see_the_esg_eligibility_question

      when_i_answer("Yes")
      then_i_am_on_the_esg_page
      and_the_trainee_is_not_on_a_training_initiative
    end

    scenario "the training initiative page goes to the funding check page" do
      given_an_eytda_trainee_with_course_details

      visit "/trainees/#{trainee.slug}/funding/training-initiative/edit"
      expect(page).to have_current_path("/trainees/#{trainee.slug}/funding/confirm")
    end

    scenario "with no ESG for the year" do
      given_an_eytda_trainee_with_course_details

      when_i_visit_the_funding_eligibility_page
      expect(page).to have_text("There is no Employer Support Grant (ESG) available")
      expect(page).not_to have_text("training grant")
    end

    scenario "other early years routes still choose a training initiative" do
      given_a_trainee_exists(:early_years_salaried, :with_valid_itt_start_date, progress: Progress.new(course_details: true))

      when_i_visit_the_funding_eligibility_page
      when_i_answer("Yes")
      expect(page).to have_current_path("/trainees/#{trainee.slug}/funding/training-initiative/edit")
    end
  end

  context "without the funding eligibility step", feature_funding_eligibility_step: false do
    scenario "the funding task starts at the ESG" do
      given_an_eytda_trainee_with_course_details
      and_an_esg_exists

      visit "/trainees/#{trainee.slug}"
      within("li.funding") { click_on "Funding" }
      then_i_am_on_the_esg_page
    end
  end

private

  def given_an_eytda_trainee_with_course_details
    given_a_trainee_exists(:early_years_teacher_degree_apprenticeship, :with_valid_itt_start_date, progress: Progress.new(course_details: true))
  end

  def and_an_esg_exists
    allocation_subject = create(:allocation_subject)
    create(:subject_specialism, allocation_subject: allocation_subject, name: trainee.course_subject_one)
    trainee.update!(course_allocation_subject: allocation_subject)

    { 1 => 16_500, 2 => 11_000, 3 => 9_000 }.each do |training_year, amount|
      funding_method = create(:funding_method, training_route: trainee.training_route, funding_type: FUNDING_TYPE_ENUMS[:grant],
                                               academic_cycle: trainee.start_academic_cycle, amount: amount, training_year: training_year)
      create(:funding_method_subject, funding_method:, allocation_subject:)
    end
  end

  def when_i_visit_the_funding_eligibility_page
    visit "/trainees/#{trainee.slug}/funding/funding-eligibility/edit"
  end

  def then_i_see_the_esg_eligibility_question
    expect(page).to have_text("Providers receive an Employer Support Grant (ESG) for each year of the EYTDA.")
    expect(page).to have_text("For information about ESG eligibility, refer to the guidance:")
    expect(page).to have_text("Is the trainee eligible for the ESG?")
    expect(page).to have_link(
      "EYTDA Employer Support Grant guidance",
      href: "https://www.gov.uk/government/publications/early-years-teacher-degree-apprenticeship-guidance-for-training-providers",
    )
    expect(page).not_to have_text("training grant")
    expect(page.find("main").text).not_to match(/\bITT\b|EYITT|initial teacher training/i)
  end

  def when_i_answer(answer)
    choose(answer)
    click_on "Continue"
  end

  def then_i_am_on_the_esg_page
    expect(page).to have_current_path("/trainees/#{trainee.slug}/funding/bursary/edit")
    expect(page).to have_css("h1", text: "Employer Support Grant (ESG) funding")
  end

  def and_the_trainee_is_not_on_a_training_initiative
    expect(trainee.reload.training_initiative).to eq(ROUTE_INITIATIVES_ENUMS[:no_initiative])
  end
end
