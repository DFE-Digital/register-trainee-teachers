# frozen_string_literal: true

require "rails_helper"

feature "List validation errors" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }

    before do
      @validation_error = create(:validation_error)
      given_i_am_authenticated(user: user)
    end

    scenario "list validation_errors" do
      when_i_visit_the_validation_errors_index_page
      then_i_see_the_validation_errors
    end
  end

  def when_i_visit_the_validation_errors_index_page
    validation_errors_index_page.load
  end

  def then_i_see_the_validation_errors
    expect(validation_errors_index_page).to have_text(@validation_error.form_object.underscore.humanize)
  end
end
