# frozen_string_literal: true

require "rails_helper"

feature "edit trainee record", type: :feature do
  include TrnSubmissionsHelper

  background do
    given_i_am_authenticated
    given_a_trainee_exists
    when_i_visit_the_trainee_edit_page
  end

  describe "trainee details view" do
    scenario "viewing the trainee's details" do
      then_i_see_the_trainee_name
      then_i_see_the_trn_status
      then_i_see_the_record_details
      then_i_see_the_programme_details
    end
  end

  def then_i_see_the_trainee_name
    expect(@edit_page.trainee_name.text).to include(trainee_name(trainee))
  end

  def then_i_see_the_trn_status
    expect(@edit_page.trn_status.text).to eq("Pending TRN")
  end

  def when_i_visit_the_trainee_edit_page
    @edit_page ||= PageObjects::Trainees::Edit.new
    @edit_page.load(id: trainee.id)
  end

  def then_i_see_the_record_details
    expect(@edit_page).to have_record_detail
  end

  def then_i_see_the_programme_details
    expect(@edit_page).to have_programme_detail
  end
end
