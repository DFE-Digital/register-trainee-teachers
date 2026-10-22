# frozen_string_literal: true

require "rails_helper"

feature "funding that depends on the degree or employing school", feature_funding_eligibility_step: true do
  background { given_i_am_authenticated }

  let(:cycle) { AcademicCycle.current || create(:academic_cycle, :current) }
  let(:mathematics) { create(:allocation_subject, name: AllocationSubjects::MATHEMATICS) }
  let(:mathematics_degree) { DfEReference::DegreesQuery::SUBJECTS.all.find { |s| s.name == "Mathematics" } }

  scenario "the degree must be added before funding" do
    given_a_mathematics_trainee_without_a_degree(:provider_led_postgrad)
    and_the_bursary_depends_on_the_degree

    when_i_visit_the_review_draft_page
    and_i_click_the_funding_section
    then_i_see_the_review_draft_page
    and_i_see_the_error("Funding for this route requires the previous degree to be completed first", "/trainees/#{trainee.slug}/degrees/new/type")
    and_the_task_has_the_error(".degree-details", "Complete the degree before adding funding")

    when_i_visit_the_funding_eligibility_page
    then_i_see_the_review_draft_page
    and_i_see_the_error("Funding for this route requires the previous degree to be completed first", "/trainees/#{trainee.slug}/degrees/new/type")

    when_the_trainee_has_a_degree
    and_i_visit_the_review_draft_page
    and_i_click_the_funding_section
    then_i_see_the_funding_eligibility_page
  end

  scenario "the employing school must be added before funding on a teaching apprenticeship" do
    given_a_mathematics_trainee_without_a_degree(:pg_teaching_apprenticeship)
    and_the_trainee_has_a_degree
    and_the_grant_depends_on_the_employing_school

    when_i_visit_the_review_draft_page
    and_i_click_the_funding_section
    then_i_see_the_review_draft_page
    and_i_see_the_error("Funding for this route requires the employing school to be completed first", "/trainees/#{trainee.slug}/training-partners/details/edit")
    and_the_task_has_the_error(".school-details", "Complete the employing school before adding funding")
  end

  scenario "funding that doesn't depend on them opens as today" do
    given_a_mathematics_trainee_without_a_degree(:provider_led_postgrad)
    and_the_bursary_is_for_everyone

    when_i_visit_the_review_draft_page
    and_i_click_the_funding_section
    then_i_see_the_funding_eligibility_page
  end

  scenario "the draft record has no error when the provider hasn't been sent back" do
    given_a_mathematics_trainee_without_a_degree(:provider_led_postgrad)
    and_the_bursary_depends_on_the_degree

    when_i_visit_the_review_draft_page
    then_i_see_no_error
  end

private

  def given_a_mathematics_trainee_without_a_degree(route)
    create(:subject_specialism, allocation_subject: mathematics, name: CourseSubjects::MATHEMATICS)
    given_a_trainee_exists(route, :with_valid_itt_start_date, course_subject_one: CourseSubjects::MATHEMATICS,
                                                              progress: Progress.new(course_details: true))
    trainee.update!(course_allocation_subject: mathematics, start_academic_cycle: cycle, employing_school: nil, employing_school_name: nil)
    trainee.degrees.destroy_all
  end

  def when_the_trainee_has_a_degree
    create(:degree, :uk_degree_with_details, trainee: trainee, subject_uuid: mathematics_degree.id, subject: mathematics_degree.name)
  end
  alias_method :and_the_trainee_has_a_degree, :when_the_trainee_has_a_degree

  def and_the_bursary_depends_on_the_degree
    add_funding(trainee.training_route, FUNDING_TYPE_ENUMS[:bursary], degree_relevance: :relevant)
    add_funding(trainee.training_route, FUNDING_TYPE_ENUMS[:bursary], degree_relevance: :unrelated)
  end

  def and_the_grant_depends_on_the_employing_school
    add_funding(trainee.training_route, FUNDING_TYPE_ENUMS[:grant], school_disadvantage: :disadvantaged)
    add_funding(trainee.training_route, FUNDING_TYPE_ENUMS[:grant], school_disadvantage: :non_disadvantaged)
  end

  def and_the_bursary_is_for_everyone
    add_funding(trainee.training_route, FUNDING_TYPE_ENUMS[:bursary])
  end

  def add_funding(route, funding_type, degree_relevance: nil, school_disadvantage: nil)
    funding_method = create(:funding_method, training_route: route, funding_type: funding_type, amount: 20_000, academic_cycle: cycle,
                                             degree_relevance: degree_relevance, school_disadvantage: school_disadvantage)
    create(:funding_method_subject, funding_method: funding_method, allocation_subject: mathematics)
  end

  def when_i_visit_the_review_draft_page
    review_draft_page.load(id: trainee.slug)
  end
  alias_method :and_i_visit_the_review_draft_page, :when_i_visit_the_review_draft_page

  def and_i_click_the_funding_section
    review_draft_page.funding_section.link.click
  end

  def when_i_visit_the_funding_eligibility_page
    funding_eligibility_page.load(id: trainee.slug)
  end

  def then_i_see_the_review_draft_page
    expect(review_draft_page).to be_displayed(id: trainee.slug)
  end

  def then_i_see_the_funding_eligibility_page
    expect(funding_eligibility_page).to be_displayed(id: trainee.slug)
  end

  def and_i_see_the_error(message, href)
    expect(page).to have_title(/\A\s*Error: /)
    within(".govuk-error-summary") do
      expect(page).to have_link(message, href:)
    end
  end

  def and_the_task_has_the_error(task, message)
    within(task) do
      expect(page).to have_css(".govuk-error-message", text: message)
    end
  end

  def then_i_see_no_error
    expect(page).not_to have_css(".govuk-error-summary")
    expect(page).not_to have_css(".app-task-list .govuk-error-message")
  end
end
