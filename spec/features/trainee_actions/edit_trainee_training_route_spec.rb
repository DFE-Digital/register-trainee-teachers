# frozen_string_literal: true

require "rails_helper"

feature "editing a trainee training route" do
  background do
    given_i_am_authenticated
    given_a_trainee_exists(*traits)
  end

  context "draft-trainee" do
    let(:traits) { :draft }

    context "viewing training route" do
      scenario "viewing the draft-trainee's current training route on training route page" do
        when_i_visit_the_edit_training_route_page
        then_i_see_the_course_details
        and_current_training_route_should_be_selected
      end
    end

    context "editing a draft trainee's current training route" do
      scenario "selecting a valid training route", "feature_routes.provider_led_postgrad": true do
        when_i_visit_the_edit_training_route_page
        then_i_select_provider_led_postgrad
        and_i_submit_the_new_route
        when_i_visit_the_edit_training_route_page
        and_provider_led_postgrad_should_be_selected
      end
    end

    context "editing training route from the review draft page" do
      scenario "redirects to the trainee path" do
        when_i_visit_the_review_draft_page
        and_i_click_on_the_training_route
        and_i_select_a_route
        and_i_submit_the_new_route
        then_i_am_redirected_to_the_trainee_path
      end
    end

    context "editing training route from the course details" do
      let(:traits) { :completed }

      background do
        given_a_trainee_exists(traits)
        given_a_route_has_published_courses
        given_i_am_viewing_the_course_details
        and_i_click_change_course
        then_i_should_see_the_training_routes_page
      end

      context "and the route has published courses", skip: skip_test_due_to_first_day_of_current_academic_year? do
        let(:traits) { %i[completed with_valid_itt_start_date] }

        scenario "redirects to the publish course path", feature_show_draft_trainee_course_year_choice: false do
          and_i_select_school_direct_salaried
          and_i_submit_the_new_route
          then_i_am_redirected_to_the_publish_course_details_path
        end
      end

      context "and the route is early years" do
        scenario "redirects to the manual course path", "feature_routes.early_years_postgrad": true do
          and_i_select_early_years_route
          and_i_submit_the_new_route
          then_i_am_redirected_to_the_manual_course_details_path
        end
      end

      context "and the route does not have published courses" do
        scenario "redirects to the course education phase path" do
          and_i_select_a_route_without_published_courses
          and_i_submit_the_new_route
          then_i_am_redirected_to_the_course_education_phase_path
        end
      end
    end
  end

  context "non-draft trainee" do
    let(:traits) { :submitted_for_trn }

    context "editing a registered trainee's current training route" do
      scenario "selecting a valid training route but not confirming course details", "feature_routes.provider_led_postgrad": true do
        when_i_visit_the_edit_training_route_page
        then_i_see_the_course_details
        and_i_submit_the_new_route
        when_i_visit_the_edit_training_route_page
        and_provider_led_postgrad_should_not_be_selected
        and_current_training_route_should_be_selected
      end
    end
  end

private

  def when_i_visit_the_edit_training_route_page
    trainee_edit_training_route_page.load(id: trainee.slug)
  end

  def when_i_visit_the_review_draft_page
    review_draft_page.load(id: trainee.slug)
  end

  def given_i_am_viewing_the_course_details
    confirm_course_details_page.load(id: trainee.slug)
  end

  def given_a_route_has_published_courses
    @course = create(:course_with_subjects,
                     accredited_body_code: trainee.provider.code,
                     route: "school_direct_salaried",
                     subject_names: ["Philosophy"])
  end

  def and_i_click_change_course
    confirm_course_details_page.change_course.click
  end

  def then_i_see_the_course_details
    expect(trainee_edit_training_route_page).to be_displayed
  end

  def then_i_should_see_the_training_routes_page
    expect(trainee_edit_training_route_page).to be_displayed
  end

  def and_i_select_school_direct_salaried
    trainee_edit_training_route_page.school_direct_salaried.click
  end

  def and_i_select_early_years_route
    trainee_edit_training_route_page.early_years_postgrad.click
  end

  def and_i_select_a_route_without_published_courses
    trainee_edit_training_route_page.pg_teaching_apprenticeship.click
  end

  def and_current_training_route_should_be_selected
    expect(trainee_edit_training_route_page.assessment_only).to be_checked
  end

  def then_i_select_provider_led_postgrad
    trainee_edit_training_route_page.provider_led_postgrad.click
  end

  def and_i_submit_the_new_route
    trainee_edit_training_route_page.continue_button.click
  end

  def and_provider_led_postgrad_should_be_selected
    expect(trainee_edit_training_route_page.provider_led_postgrad).to be_checked
  end

  def and_provider_led_postgrad_should_not_be_selected
    expect(trainee_edit_training_route_page.provider_led_postgrad).not_to be_checked
  end

  def and_i_click_on_the_training_route
    within("div.govuk-inset-text") do
      find("a").click
    end
  end

  def and_i_select_a_route
    trainee_edit_training_route_page.training_route_options.reject { |route|
      route.input.value.include?(trainee.training_route)
    }.first.choose
  end

  def then_i_am_redirected_to_the_trainee_path
    expect(review_draft_page).to be_displayed
  end

  def then_i_am_redirected_to_the_publish_course_details_path
    expect(publish_course_details_page).to be_displayed
  end

  def then_i_am_redirected_to_the_manual_course_details_path
    expect(course_details_page).to be_displayed
  end

  def then_i_am_redirected_to_the_course_education_phase_path
    expect(course_education_phase_page).to be_displayed
  end
end
