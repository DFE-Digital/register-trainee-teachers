# frozen_string_literal: true

require "rails_helper"

feature "the funding type page says why the amount applies", feature_funding_eligibility_step: true do
  # The years' funding is signed off, as it will be by the time trainees start.
  before { AcademicCycle.find_each { |cycle| cycle.update!(published: true) } }

  background { given_i_am_authenticated }

  let(:cycle) { AcademicCycle.current || create(:academic_cycle, :current) }
  let(:mathematics) { create(:allocation_subject, name: AllocationSubjects::MATHEMATICS) }
  let(:mathematics_degree) { DfEReference::DegreesQuery::SUBJECTS.all.find { |s| s.name == "Mathematics" } }
  let(:astronomy_degree) { DfEReference::DegreesQuery::SUBJECTS.all.find { |s| s.name == "Astronomy" } }
  let(:school) { create(:school, name: "Bluemeadow 2 High", urn: "254333") }

  scenario "a degree that isn't relevant to the course" do
    given_a_mathematics_trainee(:provider_led_postgrad)
    and_the_trainee_has_a_degree_in(astronomy_degree)
    and_the_bursary_depends_on_the_degree

    when_i_visit_the_bursary_page
    then_i_see("The trainee’s degree in Astronomy is not relevant or related to their Mathematics ITT course.")
    and_i_see("Bursary (up to £10,000)")
  end

  scenario "a relevant degree" do
    given_a_mathematics_trainee(:provider_led_postgrad)
    and_the_trainee_has_a_degree_in(mathematics_degree)
    and_the_bursary_depends_on_the_degree

    when_i_visit_the_bursary_page
    then_i_see("The trainee’s degree in Mathematics is relevant or related to their Mathematics ITT course.")
    and_i_see("Bursary (up to £20,000)")
  end

  scenario "an employing school on the list" do
    given_a_mathematics_trainee(:pg_teaching_apprenticeship)
    and_the_trainee_has_a_degree_in(mathematics_degree)
    and_the_grant_depends_on_the_employing_school
    and_the_employing_school_is_on_the_list

    when_i_visit_the_bursary_page
    then_i_see("The employing school, Bluemeadow 2 High (URN 254333), is a secondary school or special school we have identified as having a high need for teachers.")
    and_i_see("Grant (up to £15,000)")
  end

  scenario "an employing school that isn't on the list" do
    given_a_mathematics_trainee(:pg_teaching_apprenticeship)
    and_the_trainee_has_a_degree_in(mathematics_degree)
    and_the_grant_depends_on_the_employing_school

    when_i_visit_the_bursary_page
    then_i_see("The employing school, Bluemeadow 2 High (URN 254333), is not a secondary school or special school we have identified as having a high need for teachers.")
    and_i_see("Grant (up to £5,000)")
  end

  scenario "funding that doesn't depend on the degree" do
    given_a_mathematics_trainee(:provider_led_postgrad)
    and_the_trainee_has_a_degree_in(astronomy_degree)
    add_funding(FUNDING_TYPE_ENUMS[:bursary], 20_000)

    when_i_visit_the_bursary_page
    then_i_do_not_see("ITT course.")
  end

private

  def given_a_mathematics_trainee(route)
    create(:subject_specialism, allocation_subject: mathematics, name: CourseSubjects::MATHEMATICS)
    given_a_trainee_exists(route, :with_valid_itt_start_date, course_subject_one: CourseSubjects::MATHEMATICS,
                                                              funding_eligibility: :eligible,
                                                              progress: Progress.new(course_details: true))
    trainee.update!(course_allocation_subject: mathematics, start_academic_cycle: cycle, employing_school: school)
    trainee.degrees.destroy_all
    create(:relevant_degree_mapping, academic_cycle: cycle, allocation_subject: mathematics, hecos_code: mathematics_degree.hecos_code)
  end

  def and_the_trainee_has_a_degree_in(reference_subject)
    create(:degree, :uk_degree_with_details, trainee: trainee, subject_uuid: reference_subject.id, subject: reference_subject.name)
  end

  def and_the_bursary_depends_on_the_degree
    add_funding(FUNDING_TYPE_ENUMS[:bursary], 20_000, degree_relevance: :relevant)
    add_funding(FUNDING_TYPE_ENUMS[:bursary], 10_000, degree_relevance: :unrelated)
  end

  def and_the_grant_depends_on_the_employing_school
    add_funding(FUNDING_TYPE_ENUMS[:grant], 15_000, school_disadvantage: :disadvantaged)
    add_funding(FUNDING_TYPE_ENUMS[:grant], 5_000, school_disadvantage: :non_disadvantaged)
  end

  def and_the_employing_school_is_on_the_list
    create(:funding_school_designation, school: school, academic_cycle: cycle, designation: :disadvantaged)
  end

  def add_funding(funding_type, amount, degree_relevance: nil, school_disadvantage: nil)
    funding_method = create(:funding_method, training_route: trainee.training_route, funding_type: funding_type, amount: amount,
                                             academic_cycle: cycle, degree_relevance: degree_relevance, school_disadvantage: school_disadvantage)
    create(:funding_method_subject, funding_method: funding_method, allocation_subject: mathematics)
  end

  def when_i_visit_the_bursary_page
    bursary_page.load(id: trainee.slug)
  end

  def then_i_see(text)
    expect(page).to have_text(text)
  end
  alias_method :and_i_see, :then_i_see

  def then_i_do_not_see(text)
    expect(page).not_to have_text(text)
  end
end
