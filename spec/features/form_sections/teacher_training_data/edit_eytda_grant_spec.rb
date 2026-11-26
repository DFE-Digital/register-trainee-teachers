# frozen_string_literal: true

require "rails_helper"

feature "edit the Early years teacher degree apprenticeship Employer Support Grant (ESG)" do
  background { given_i_am_authenticated }

  let(:amounts) { { 1 => 16_500, 2 => 11_000, 3 => 9_000 } }

  scenario "the ESG page lists the ESG for each training year" do
    given_a_trainee_exists(:early_years_teacher_degree_apprenticeship, :with_valid_itt_start_date)
    and_an_esg_exists_for_each_training_year
    when_i_visit_the_bursary_page
    then_i_see_the_esg_for(1, 2, 3)

    when_i_apply_for_the_esg
    and_i_submit_the_form
    then_i_am_redirected_to_the_funding_confirmation_page
    and_i_see_the_esg_for(1, 2, 3)
    and_i_do_not_see_a_training_initiative
  end

  scenario "a Year 2 entry trainee gets the ESG for Year 2 and Year 3" do
    given_a_trainee_exists(:early_years_teacher_degree_apprenticeship, :with_valid_itt_start_date, level_five_qualification: true)
    and_an_esg_exists_for_each_training_year
    when_i_visit_the_bursary_page
    then_i_see_the_esg_for(2, 3)
    and_i_see_the_year_two_entry_text

    when_i_apply_for_the_esg
    and_i_submit_the_form
    then_i_am_redirected_to_the_funding_confirmation_page
    and_i_see_the_esg_for(2, 3)
  end

private

  def and_an_esg_exists_for_each_training_year
    allocation_subject = create(:allocation_subject)
    create(:subject_specialism, allocation_subject: allocation_subject, name: trainee.course_subject_one)
    trainee.update!(course_allocation_subject: allocation_subject)

    amounts.each do |training_year, amount|
      funding_method = create(:funding_method, training_route: trainee.training_route, funding_type: FUNDING_TYPE_ENUMS[:grant],
                                               academic_cycle: trainee.start_academic_cycle, amount: amount, training_year: training_year)
      create(:funding_method_subject, funding_method:, allocation_subject:)
    end
  end

  def when_i_visit_the_bursary_page
    bursary_page.load(id: trainee.slug)
  end

  def then_i_see_the_esg_for(*years)
    expect(page).to have_css("h1", text: "Employer Support Grant (ESG) funding")
    expect(page).to have_text("The ESG is available for each training year of the EYTDA.")
    expect(page).to have_text("ESG amount for trainees starting in #{trainee.start_academic_cycle.label}")
    expect_amounts_for(years)
    expect(page).to have_text("Yes, apply for the ESG")
    expect(page).to have_text("The ESG is paid each training year. This trainee is in #{FundingManager.new(trainee.reload).training_year_label}")
    expect(page).not_to have_text("grant")
  end

  def and_i_see_the_year_two_entry_text
    expect(page).to have_text("The trainee enters the EYTDA at Year 2, so their course is 2 years and they get the ESG for Year 2 and Year 3.")
  end

  def when_i_apply_for_the_esg
    page.choose("Yes, apply for the ESG")
  end

  def and_i_submit_the_form
    bursary_page.submit_button.click
  end

  def then_i_am_redirected_to_the_funding_confirmation_page
    expect(confirm_funding_page).to be_displayed(id: trainee.slug)
  end

  def and_i_see_the_esg_for(*years)
    expect(page).to have_text("Employer Support Grant (ESG)")
    expect(page).to have_text("Estimated ESG amount:")
    expect_amounts_for(years)
  end

  def and_i_do_not_see_a_training_initiative
    expect(page).not_to have_text("Training initiative")
  end

  def expect_amounts_for(years)
    start_year = trainee.start_academic_cycle.start_year
    first_year = years.first
    labels = (1..3).index_with { |year| Funding::AmountMatrix.year_label(year, start_year - first_year + 1) }

    years.each do |year|
      expect(page).to have_text(labels[year])
      expect(page).to have_text("£#{amounts[year].to_fs(:delimited)}")
    end
    (labels.keys - years).each { |year| expect(page).not_to have_text(labels[year]) }
  end
end
