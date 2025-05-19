# frozen_string_literal: true

require "rails_helper"

feature "Viewing sidekiq dead jobs" do
  let(:user) { create(:user, system_admin: true) }
  let!(:trainee) { create(:trainee, :submitted_for_trn, first_names: "James Blint") }
  let(:dead_jobs_data) do
    [
      OpenStruct.new(
        item: {
          wrapped: "Dqt::UpdateTraineeJob",
          args:
          [
            {
              arguments: [
                { _aj_globalid: "gid://register-trainee-teachers/Trainee/#{trainee.id}" },
              ],
            },
          ],
          error_message: 'status: 400, body: {"title":"Teacher has no incomplete ITT record","status":400,"errorCode":10005}, headers: ',
          jid: "1234",
          enqueued_at: 73.hours.ago.to_i,
        }.with_indifferent_access,
      ),
      # OpenStruct.new(
      #   item: {
      #     wrapped: "Dqt::UpdateTraineeJob",
      #     args:
      #     [
      #       {
      #         arguments: [
      #           { trainee: { _aj_globalid: "gid://register-trainee-teachers/Trainee/#{trainee.id}" } },
      #         ],
      #       },
      #     ],
      #     error_message: 'status: 400, body: {"title":"Teacher has no incomplete ITT record","status":400,"errorCode":10005}, headers: ',
      #     jid: "1234",
      #     enqueued_at: 73.hours.ago.to_i,
      #   }.with_indifferent_access,
      # ),
    ]
  end

  around do |example|
    Timecop.freeze(Time.zone.now.change(hour: 12, minute: 0)) { example.run }
  end

  before do
    allow_any_instance_of(SystemAdmin::DeadJobsController).to receive(:job).and_return(nil) # rubocop:disable RSpec/AnyInstance
    given_i_am_authenticated(user:)
    and_dead_jobs_exist
    when_i_visit_the_dead_jobs_tab
  end

  scenario "shows dead_jobs page" do
    then_i_see_the_dead_jobs_page
    when_i_click_view
    then_i_am_taken_to_the_dqt_update_page
    then_i_see_the_trainee
    and_the_trainee_view_link_is_visibile
    and_when_i_click_view
    then_i_am_redirected_to_the_record_page
  end

  scenario "doesn't show dead jobs for soft-deleted trainees" do
    when_the_trainee_is_soft_deleted
    and_i_visit_the_dead_jobs_tab
    then_i_see_the_dead_jobs_page
    and_there_are_no_dead_jobs
  end

  scenario "retrying a job" do
    when_i_click_view
    and_dead_jobs_exist
    and_when_i_click_retry
    then_the_job_is_retried
  end

  scenario "deleting a job" do
    when_i_click_view
    and_dead_jobs_exist
    and_when_i_click_delete
    then_the_job_is_deleted
  end

  scenario "view job details", skip: skip_test_due_to_first_day_of_current_academic_year? do
    when_i_click_view
    then_i_am_taken_to_the_dqt_update_page
    and_i_can_see_the_data_associated_with_the_job
  end

  def when_i_visit_the_dead_jobs_tab
    admin_dead_jobs_page.load
  end
  alias_method :and_i_visit_the_dead_jobs_tab, :when_i_visit_the_dead_jobs_tab

  def and_dead_jobs_exist
    allow(Sidekiq::DeadSet).to receive(:new).and_return(dead_jobs_data)
  end

  def then_i_see_the_dead_jobs_page
    expect(admin_dead_jobs_page).to have_text("Dead background Jobs")
  end

  def when_the_trainee_is_soft_deleted
    trainee.discard
  end

  def and_there_are_no_dead_jobs
    expect(admin_dead_jobs_page).not_to have_link("View", href: dead_job_path(DeadJobs::DqtUpdateTrainee))
    expect(admin_dead_jobs_page).to have_text("DQT Update Trainee 0")
  end

  def when_i_click_view
    admin_dead_jobs_page.dqt_update_trainee_dead_jobs_view_button.click
  end

  def then_i_am_taken_to_the_dqt_update_page
    expect(admin_dead_jobs_dqt_update_trainee).to be_displayed
  end

  def and_i_can_see_the_data_associated_with_the_job
    expect(page).to have_text("#{trainee.id} #{trainee.full_name} #{trainee.date_of_birth} submitted_for_trn 3")
  end

  def then_i_see_the_trainee
    expect(admin_dead_jobs_dqt_update_trainee).to have_text("James Blint")
  end

  def and_the_trainee_view_link_is_visibile
    expect(admin_dead_jobs_dqt_update_trainee).to have_text("View")
  end

  def and_when_i_click_view
    admin_dead_jobs_dqt_update_trainee.view_trainee_button.click
  end

  def and_when_i_click_retry
    admin_dead_jobs_dqt_update_trainee.retry_trainee_button.click
  end

  def and_when_i_click_delete
    admin_dead_jobs_dqt_update_trainee.delete_trainee_button.click
  end

  def then_the_job_is_retried
    expect(admin_dead_jobs_dqt_update_trainee).to have_text("Job will be retried imminently")
  end

  def then_the_job_is_deleted
    expect(admin_dead_jobs_dqt_update_trainee).to have_text("Job successfully deleted")
  end

  def then_i_am_redirected_to_the_record_page
    expect(record_page).to be_displayed(id: trainee.slug)
  end
end
