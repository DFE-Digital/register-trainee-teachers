# frozen_string_literal: true

require "rails_helper"

feature "deleting a degree" do
  background { given_i_am_authenticated }

  scenario "with UK degree" do
    given_a_trainee_with_a_uk_degree
    when_i_visit_the_degrees_confirm_page
    and_i_click_the_delete_button
    then_i_should_not_see_any_degree
  end

  scenario "with not UK degree" do
    given_a_trainee_with_a_non_uk_degree
    when_i_visit_the_degrees_confirm_page
    and_i_click_the_delete_button
    then_i_should_not_see_any_degree
  end

private

  def given_a_trainee_with_a_uk_degree
    uk_trainee
  end

  def given_a_trainee_with_a_non_uk_degree
    non_uk_trainee
  end

  def and_i_click_the_delete_button
    degrees_confirm_page.delete_degree.click
  end

  def then_i_should_not_see_any_degree
    expect(degrees_confirm_page.page_heading.text).to eql("Confirm degrees")
    expect(degrees_confirm_page.main_content.find_all(".govuk-summary-list__row")).to be_empty
  end

  def when_i_visit_the_degrees_confirm_page
    degrees_confirm_page.load(trainee_id: trainee.slug)
    expect(degrees_confirm_page).to be_displayed(trainee_id: trainee.slug)
  end

  def trainee
    (@uk_trainee || @non_uk_trainee)
  end

  def uk_trainee
    @uk_trainee ||= create(:trainee, provider: current_user.provider).tap do |t|
      t.degrees << build(:degree, :uk_degree_with_details)
    end
  end

  def non_uk_trainee
    @non_uk_trainee ||= create(:trainee, provider: current_user.provider).tap do |t|
      t.degrees << build(:degree, :non_uk_degree_with_details)
    end
  end
end
