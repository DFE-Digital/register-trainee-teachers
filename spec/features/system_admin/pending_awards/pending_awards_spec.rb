# frozen_string_literal: true

require "rails_helper"

feature "pending awards" do
  attr_reader :trainee

  context "when I am authenticated as a system admin" do
    before do
      given_i_am_authenticated_as_system_admin
      and_i_have_a_trainee_with_a_pending_award
    end

    scenario "shows pending awards page" do
      when_there_are_no_jobs_in_the_retry_or_dead_queue
      and_i_visit_the_pending_awards_page
      then_i_see_the_pending_awards_page
      and_i_see_the_trainee
    end

    scenario "shows last run date if there is a job in the dead queue" do
      when_there_is_a_job_in_the_dead_queue
      and_i_visit_the_pending_awards_page
      then_i_see_the_pending_awards_page
      and_i_see_that_the_job_status_is_dead
    end

    scenario "shows next schedule date if there is a job in the retry queue" do
      when_there_is_a_job_in_the_retry_queue
      and_i_visit_the_pending_awards_page
      then_i_see_the_pending_awards_page
      and_i_see_that_the_job_status_is_retrying
    end

    scenario "shows details for individual trainees recommended for award" do
      when_there_are_no_jobs_in_the_retry_or_dead_queue
      and_i_visit_the_pending_awards_page
      then_i_see_the_pending_awards_page
      and_i_click_view
      then_i_see_the_trainee_details
    end
  end

  context "when I am authenticated as a regular user (not a system admin)" do
    before do
      given_i_am_authenticated
      and_i_have_a_trainee_with_a_pending_award
    end

    scenario "the pending awards page is inaccessible" do
      expect { and_i_visit_the_pending_awards_page }.to raise_error(ActionController::RoutingError)
    end
  end

  def and_i_have_a_trainee_with_a_pending_award
    @trainee = create(:trainee, :recommended_for_award)
  end

  def and_i_visit_the_pending_awards_page
    visit "/system-admin/pending_awards"
  end

  def then_i_see_the_pending_awards_page
    expect(page).to have_text("Trainees Pending Award")
  end

  def and_i_see_the_trainee
    expect(page).to have_text(trainee.first_names)
    expect(page).to have_text(trainee.last_name)
  end

  def and_i_click_view
    click_on "View"
  end

  def then_i_see_the_trainee_details
    expect(page).to have_current_path(trainee_personal_details_path(trainee))
  end

  def when_there_is_a_job_in_the_dead_queue
    allow(Trs::FindDeadJobs).to receive(:call).and_return(
      @trainee.id => {
        job_id: "dead_job_id",
        error_message: "dead_job_error_message",
        scheduled_at: 3.days.ago,
      },
    )
    allow(Trs::FindRetryJobs).to receive(:call).and_return({})
  end

  def when_there_is_a_job_in_the_retry_queue
    allow(Trs::FindRetryJobs).to receive(:call).and_return(
      @trainee.id => {
        job_id: "retry_job_id",
        error_message: "retry_job_error_message",
        scheduled_at: 3.days.from_now,
      },
    )
    allow(Trs::FindDeadJobs).to receive(:call).and_return({})
  end

  def when_there_are_no_jobs_in_the_retry_or_dead_queue
    allow(Trs::FindDeadJobs).to receive(:call).and_return({})
    allow(Trs::FindRetryJobs).to receive(:call).and_return({})
  end

  def and_i_see_that_the_job_status_is_dead
    expect(page).to have_text("dead")
  end

  def and_i_see_that_the_job_status_is_retrying
    expect(page).to have_text("retrying")
  end
end
