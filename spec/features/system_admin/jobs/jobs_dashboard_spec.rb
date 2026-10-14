# frozen_string_literal: true

require "rails_helper"

feature "jobs dashboard" do
  context "when I am authenticated as a system admin" do
    before do
      given_i_am_authenticated_as_system_admin
    end

    scenario "shows the jobs dashboard" do
      when_i_visit_the_jobs_dashboard
      then_i_see_the_queues
    end
  end

  context "when I am authenticated as a regular user (not a system admin)" do
    before do
      given_i_am_authenticated
    end

    scenario "the jobs dashboard is inaccessible" do
      expect { when_i_visit_the_jobs_dashboard }.to raise_error(ActionController::RoutingError)
    end
  end

  def when_i_visit_the_jobs_dashboard
    visit "/system-admin/jobs"
  end

  def then_i_see_the_queues
    expect(page).to have_text("Queues")
    expect(page).to have_text("Pending jobs")
  end
end
