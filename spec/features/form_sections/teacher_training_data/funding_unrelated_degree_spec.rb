# frozen_string_literal: true

require "rails_helper"

feature "funding for a trainee without a relevant degree" do
  background { given_i_am_authenticated }

  let(:cycle) { AcademicCycle.current || create(:academic_cycle, :current) }
  let(:chemistry) { create(:allocation_subject, name: AllocationSubjects::CHEMISTRY) }
  let(:route) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
  let(:chemistry_degree) { DfEReference::DegreesQuery::SUBJECTS.all.find { |s| s.name == "Chemistry" } }
  let(:history_degree) { DfEReference::DegreesQuery::SUBJECTS.all.find { |s| s.name == "History" } }

  scenario "the bursary isn't offered, the scholarship is" do
    given_a_chemistry_trainee_with_a_history_degree
    and_the_bursary_is_only_for_a_relevant_degree
    and_there_is_a_scholarship_for_everyone

    when_i_visit_the_bursary_page
    then_i_see_the_scholarship_but_not_the_bursary
  end

  scenario "a subject with only a bursary shows the degree reason", feature_funding_eligibility_step: true do
    given_a_chemistry_trainee_with_a_history_degree
    and_the_bursary_is_only_for_a_relevant_degree

    when_i_visit_the_funding_eligibility_page
    then_i_see_the_degree_reason

    when_i_visit_the_confirm_funding_page
    then_i_see_bursary_not_available_for_the_degree
  end

private

  def given_a_chemistry_trainee_with_a_history_degree
    create(:subject_specialism, allocation_subject: chemistry, name: CourseSubjects::CHEMISTRY)
    given_a_trainee_exists(:provider_led_postgrad, :with_valid_itt_start_date, course_subject_one: CourseSubjects::CHEMISTRY,
                                                                               progress: Progress.new(course_details: true))
    trainee.update!(course_allocation_subject: chemistry, start_academic_cycle: cycle)
    trainee.degrees.destroy_all
    create(:degree, :uk_degree_with_details, trainee: trainee, subject_uuid: history_degree.id, subject: history_degree.name)
    create(:relevant_degree_mapping, academic_cycle: cycle, allocation_subject: chemistry, hecos_code: chemistry_degree.hecos_code)
  end

  def and_the_bursary_is_only_for_a_relevant_degree
    add_funding(FUNDING_TYPE_ENUMS[:bursary], 29_000, degree_relevance: :relevant)
    add_funding(FUNDING_TYPE_ENUMS[:bursary], nil, degree_relevance: :unrelated, availability: :not_available)
  end

  def and_there_is_a_scholarship_for_everyone
    add_funding(FUNDING_TYPE_ENUMS[:scholarship], 31_000)
  end

  def add_funding(funding_type, amount, degree_relevance: nil, availability: :available)
    funding_method = create(:funding_method, training_route: route, funding_type: funding_type, amount: amount,
                                             academic_cycle: cycle, degree_relevance: degree_relevance, availability: availability)
    create(:funding_method_subject, funding_method: funding_method, allocation_subject: chemistry)
  end

  def when_i_visit_the_bursary_page
    bursary_page.load(id: trainee.slug)
  end

  def then_i_see_the_scholarship_but_not_the_bursary
    expect(page).to have_text("Scholarship (up to £31,000)")
    expect(page).not_to have_text("Bursary (up to")
  end

  def when_i_visit_the_funding_eligibility_page
    funding_eligibility_page.load(id: trainee.slug)
  end

  def then_i_see_the_degree_reason
    expect(page).to have_text("A bursary isn’t available for Chemistry because the trainee’s degree (History) isn’t relevant to the subject.")
  end

  def when_i_visit_the_confirm_funding_page
    confirm_funding_page.load(id: trainee.slug)
  end

  def then_i_see_bursary_not_available_for_the_degree
    expect(page).to have_text("Bursary not available")
    expect(page).to have_text("Unrelated degree (History)")
  end
end
