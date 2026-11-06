# frozen_string_literal: true

require "rails_helper"

feature "edit the Early years teacher degree apprenticeship grant" do
  background { given_i_am_authenticated }

  let(:amounts) { { 1 => 16_500, 2 => 11_000, 3 => 11_000 } }

  scenario "the grant page lists the grant for each training year" do
    given_a_trainee_exists(:early_years_teacher_degree_apprenticeship, :with_valid_itt_start_date)
    and_a_grant_exists_for_each_training_year
    when_i_visit_the_bursary_page
    then_i_see_the_grant_for_each_training_year

    when_i_apply_for_the_grant
    and_i_submit_the_form
    then_i_am_redirected_to_the_funding_confirmation_page
    and_i_see_the_current_training_year_grant
  end

private

  def and_a_grant_exists_for_each_training_year
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

  def then_i_see_the_grant_for_each_training_year
    start_year = trainee.start_academic_cycle.start_year

    expect(page).to have_text("has a grant available for each training year")
    expect(page).to have_text("Grant for trainees starting in #{trainee.start_academic_cycle.label}")
    amounts.each do |training_year, amount|
      expect(page).to have_text(Funding::AmountMatrix.year_label(training_year, start_year))
      expect(page).to have_text("£#{amount.to_fs(:delimited)}")
    end
    expect(page).to have_text("Yes, apply for a grant")
    expect(page).to have_text("This trainee is in #{FundingManager.new(trainee.reload).training_year_label}")
  end

  def when_i_apply_for_the_grant
    page.choose("Yes, apply for a grant")
  end

  def and_i_submit_the_form
    bursary_page.submit_button.click
  end

  def then_i_am_redirected_to_the_funding_confirmation_page
    expect(confirm_funding_page).to be_displayed(id: trainee.slug)
  end

  def and_i_see_the_current_training_year_grant
    manager = FundingManager.new(trainee.reload)
    expect(page).to have_text("#{ActionController::Base.helpers.number_to_currency(manager.grant_amount, precision: 0, unit: '£')} estimated grant (#{manager.training_year_label})")
  end
end
