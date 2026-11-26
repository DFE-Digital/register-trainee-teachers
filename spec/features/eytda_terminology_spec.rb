# frozen_string_literal: true

require "rails_helper"

# The early years teacher degree apprenticeship is a separate route from ITT,
# so its pages don't say "ITT" or "EYITT". They use Register's "trainee"
# wording, with "course" where other routes say "ITT".
feature "early years teacher degree apprenticeship terminology",
        "feature_routes.early_years_teacher_degree_apprenticeship": true do
  background { given_i_am_authenticated }

  scenario "the draft pages don't mention ITT" do
    given_a_trainee_exists(:early_years_teacher_degree_apprenticeship, :draft, :with_valid_itt_start_date,
                           progress: Progress.new(course_details: true))

    %w[review-draft check-details course-details/confirm contact-details/edit training-partners/details/edit placements/details/edit].each do |page_path|
      visit "/trainees/#{trainee.slug}/#{page_path}"
      then_the_page_does_not_mention_itt(page_path)
    end

    visit "/trainees/#{trainee.slug}/course-details/confirm"
    expect(page).to have_css("h1", text: "Confirm trainee's course details")
    expect(page).to have_text("Course start date")
    expect(page).to have_text("Expected end date")
    expect(page).to have_css(".govuk-summary-list__row.study-mode", text: "Full-time")
    expect(page).not_to have_text("Full time or part time")

    visit "/trainees/#{trainee.slug}/check-details"
    expect(page).to have_text("Training partner and employing setting not started")
    expect(page).not_to have_text("Schools not started")

    visit "/trainees/#{trainee.slug}/review-draft"
    expect(page).to have_text("Trainee on the Early Years Teacher Degree Apprenticeship (EYTDA) route.")
    expect(page).to have_text("About their training")
  end

  scenario "the course details errors don't mention ITT" do
    given_a_trainee_exists(:early_years_teacher_degree_apprenticeship, :draft)

    visit "/trainees/#{trainee.slug}/course-details/edit"
    ["Course start date", "Expected end date"].each do |legend|
      within(:fieldset, legend) { all("input").each { |input| input.set("") } }
    end
    click_on "Continue"
    expect(page).to have_text("Enter a course start date")
    expect(page).to have_text("Enter an expected end date")
    then_the_page_does_not_mention_itt("course-details/edit")
  end

  scenario "the record and status pages don't mention ITT" do
    given_a_trainee_exists(:early_years_teacher_degree_apprenticeship, :trn_received, :with_valid_itt_start_date)

    %w[trainee-start-date/edit trainee-start-status/edit start-date-verification withdrawal-forbidden].each do |page_path|
      visit "/trainees/#{trainee.slug}/#{page_path}"
      then_the_page_does_not_mention_itt(page_path)
    end

    visit "/trainees/#{trainee.slug}/trainee-start-date/edit"
    expect(page).to have_css("h1", text: "When did the trainee start their course?")

    visit "/trainees/#{trainee.slug}"
    expect(page).to have_text("Trainee start date")
    expect(page).to have_text("About their training")
    expect(page).not_to have_text("ITT start date")
  end

  scenario "other routes keep today's wording" do
    given_a_trainee_exists(:early_years_salaried, :draft, :with_valid_itt_start_date, progress: Progress.new(course_details: true))

    visit "/trainees/#{trainee.slug}/course-details/confirm"
    expect(page).to have_text("ITT start date")
    expect(page).to have_css("h1", text: "Confirm trainee's course details")

    visit "/trainees/#{trainee.slug}/review-draft"
    expect(page).to have_text("About their teacher training")
  end

private

  def then_the_page_does_not_mention_itt(page_path)
    text = page.find("main").text
    expect(text).not_to match(/\bITT\b|EYITT|initial teacher training/i), "#{page_path} mentions ITT: #{text[/.{0,40}(\bITT\b|EYITT|initial teacher training).{0,40}/i]}"

    # Only the route's name says "apprenticeship".
    without_route_name = text.gsub(/(Early Years )?Teacher Degree Apprenticeship/i, "")
    expect(without_route_name).not_to match(/apprentice/i), "#{page_path} says apprentice: #{without_route_name[/.{0,40}apprentice.{0,40}/i]}"
  end
end
