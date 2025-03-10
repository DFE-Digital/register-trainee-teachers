# frozen_string_literal: true

require "rails_helper"

feature "Viewing duplicate HESA trainees" do
  let(:user) { create(:user, system_admin: true) }

  scenario "menu item is hidden when feature flag is off", feature_duplicate_checking: false do
    given_i_am_authenticated(user:)
    when_i_visit users_path
    then_i_should_not_see_the_duplicate_hesa_trainees_link
  end

  scenario "shows the duplicate HESA trainees", feature_duplicate_checking: true do
    given_i_am_authenticated(user:)
    and_there_are_duplicate_hesa_trainees
    when_i_visit_the_duplicate_hesa_trainees_index_page
    then_i_should_see_the_duplicate_hesa_trainees

    when_i_click_on_the_trainee_link
    then_i_should_see_the_trainee_page
  end

  def and_there_are_duplicate_hesa_trainees
    @trainee_one = create(:trainee, :imported_from_hesa)
    @trainee_two = create(:trainee, :imported_from_hesa, email: @trainee_one.email)

    @duplicate_hesa_trainee_one = create(
      :potential_duplicate_trainee,
      trainee: @trainee_one,
      group_id: SecureRandom.uuid,
    )
    @duplicate_hesa_trainee_two = create(
      :potential_duplicate_trainee,
      trainee: @trainee_two,
      group_id: @duplicate_hesa_trainee_one.group_id,
    )
  end

  def when_i_visit_the_duplicate_hesa_trainees_index_page
    when_i_visit users_path
    click_on "Duplicate HESA trainees"
  end

  def then_i_should_not_see_the_duplicate_hesa_trainees_link
    expect(page).not_to have_link("Duplicate HESA trainees")
  end

  def then_i_should_see_the_duplicate_hesa_trainees
    expect(page).to have_content(@trainee_one.short_name)
    expect(page).to have_content(@trainee_two.short_name)
  end

  def when_i_click_on_the_trainee_link
    click_on @trainee_one.short_name
  end

  def then_i_should_see_the_trainee_page
    expect(page).to have_content(@trainee_one.full_name)
    expect(page).to have_current_path(trainee_review_drafts_path(@trainee_one))
  end

  alias_method :when_i_visit, :visit
end
