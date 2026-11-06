# frozen_string_literal: true

require "rails_helper"

feature "completing funding with draft amounts (internal testing)",
        feature_funding_draft_amounts_in_journey: true,
        feature_funding_eligibility_step: true do
  background { given_i_am_authenticated }

  let(:draft_cycle) { AcademicCycle.for_year(AcademicCycle.current.start_year + 1) || create(:academic_cycle, next_cycle: true) }
  let(:amounts) { { 1 => 1_000, 2 => 2_000, 3 => 3_000 } }

  scenario "the funding section can be completed, with the banner, but no TRN can be requested" do
    given_an_eytda_trainee_starting_in_a_draft_year
    and_the_draft_year_has_grants_for_each_training_year

    when_i_visit_the_funding_eligibility_page
    then_i_see_the_amount_not_signed_off_banner
    and_i_answer_eligible

    when_i_choose_not_on_a_training_initiative
    then_i_see_the_draft_training_year_grants
    and_i_see_the_amount_not_signed_off_banner_again

    when_i_apply_for_the_grant
    then_i_am_on_the_confirm_funding_page_with_the_banner
    and_the_trainee_is_applying_for_the_grant

    when_i_visit_the_check_details_page
    then_i_see_that_no_trn_can_be_requested
  end

private

  def given_an_eytda_trainee_starting_in_a_draft_year
    given_a_trainee_exists(
      :early_years_teacher_degree_apprenticeship,
      itt_start_date: Date.new(draft_cycle.start_year, 9, 10),
      itt_end_date: Date.new(draft_cycle.start_year + 4, 7, 1),
      trainee_start_date: Date.new(draft_cycle.start_year, 9, 10),
      progress: Progress.new(course_details: true),
    )
    expect(trainee.reload.start_academic_cycle).to eq(draft_cycle)
    expect(draft_cycle.published).to be(false)
  end

  def and_the_draft_year_has_grants_for_each_training_year
    allocation_subject = create(:allocation_subject, name: AllocationSubjects::EARLY_YEARS_ITT)
    create(:subject_specialism, allocation_subject: allocation_subject, name: trainee.course_subject_one)
    trainee.update!(course_allocation_subject: allocation_subject)

    amounts.each do |training_year, amount|
      funding_method = create(:funding_method, training_route: trainee.training_route, funding_type: FUNDING_TYPE_ENUMS[:grant],
                                               academic_cycle: draft_cycle, amount: amount, training_year: training_year)
      create(:funding_method_subject, funding_method:, allocation_subject:)
    end
  end

  def when_i_visit_the_funding_eligibility_page
    funding_eligibility_page.load(id: trainee.slug)
  end

  def then_i_see_the_amount_not_signed_off_banner
    expect(page).to have_text("Amount not signed off")
    expect(page).to have_text("These amounts are from the #{draft_cycle.label} draft and haven’t been signed off")
    expect(page).to have_text("Is the trainee eligible for a training grant?")
  end

  def and_i_answer_eligible
    funding_eligibility_page.eligible.click
    funding_eligibility_page.submit_button.click
    expect(training_initiative_page).to be_displayed(id: trainee.slug)
  end

  def when_i_choose_not_on_a_training_initiative
    page.choose("Not on a training initiative")
    training_initiative_page.submit_button.click
  end

  def then_i_see_the_draft_training_year_grants
    expect(bursary_page).to be_displayed(id: trainee.slug)
    amounts.each do |training_year, amount|
      expect(page).to have_text(Funding::AmountMatrix.year_label(training_year, draft_cycle.start_year))
      expect(page).to have_text("£#{amount.to_fs(:delimited)}")
    end
  end

  def and_i_see_the_amount_not_signed_off_banner_again
    expect(page).to have_text("Amount not signed off")
  end

  def when_i_apply_for_the_grant
    page.choose("Yes, apply for a grant")
    bursary_page.submit_button.click
  end

  def then_i_am_on_the_confirm_funding_page_with_the_banner
    expect(confirm_funding_page).to be_displayed(id: trainee.slug)
    expect(page).to have_text("Amount not signed off")
  end

  def and_the_trainee_is_applying_for_the_grant
    expect(trainee.reload.applying_for_grant).to be(true)
    expect(trainee.funding_eligibility).to eq(FUNDING_ELIGIBILITIES[:eligible])
  end

  def when_i_visit_the_check_details_page
    check_details_page.load(id: trainee.slug)
  end

  def then_i_see_that_no_trn_can_be_requested
    expect(page).to have_text("Funding uses #{draft_cycle.label} amounts that haven’t been signed off. You can’t request a TRN until they have.")
    expect(Submissions::TrnValidator.new(trainee: trainee.reload)).not_to be_valid
  end
end
