# frozen_string_literal: true

require "rails_helper"

feature "Viewing sidekiq dead jobs" do
  let(:user) { create(:user, system_admin: true) }
  let!(:trainee) { create(:trainee, :submitted_for_trn, first_names: "James Blint", id: 10001) }

  before do
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

  def when_i_visit_the_dead_jobs_tab
    admin_dead_jobs_page.load
  end

  def and_dead_jobs_exist
    allow(Sidekiq::DeadSet).to receive(:new).and_return(
      [
        OpenStruct.new(
          item: {
            wrapped: "Dqt::UpdateTraineeJob",
            args:
              [
                {
                  arguments: [
                    { _aj_globalid: "gid://register-trainee-teachers/Trainee/#{trainee.id}" },
                    { _aj_serialized: "ActiveJob::Serializers::TimeWithZoneSerializer", value: "2023-01-15T00:00:42.798653522Z" },
                  ],
                },
              ],
            error_message: 'status: 400, body: {"title":"Teacher has no incomplete ITT record","status":400,"errorCode":10005}, headers: ',
          }.with_indifferent_access,
        ),
      ],
    )
  end

  def then_i_see_the_dead_jobs_page
    expect(admin_dead_jobs_page).to have_text("Dead background Jobs")
  end

  def when_i_click_view
    admin_dead_jobs_page.dqt_update_trainee_dead_jobs_view_button.click
  end

  def then_i_am_taken_to_the_dqt_update_page
    expect(admin_dead_jobs_dqt_update_trainee).to be_displayed
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

  def then_i_am_redirected_to_the_record_page
    expect(record_page).to be_displayed(id: trainee.slug)
  end
end
