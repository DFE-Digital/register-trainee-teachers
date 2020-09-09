require "rails_helper"

feature "View trainees", type: :feature do
  scenario "viewing the personal details of trainee" do
    given_a_trainee_already_exists
    when_i_view_the_trainee_index_page
    and_i_click_on_trainne_name
    then_i_should_see_the_trainee_details
  end

  def given_a_trainee_already_exists
    @trainee = create(:trainee)
  end

  def when_i_view_the_trainee_index_page
    @index_page ||= PageObjects::Trainees::Index.new
    @index_page.load
  end

  def and_i_click_on_trainne_name
    @index_page.trainee_name.first.click
  end

  def then_i_should_see_the_trainee_details
    @show_page ||= PageObjects::Trainees::Show.new
    expect(@show_page).to be_displayed(id: @trainee.id)
  end
end
