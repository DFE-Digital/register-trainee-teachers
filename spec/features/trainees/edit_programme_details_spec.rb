require "rails_helper"

feature "edit programme details", type: :feature do
  scenario "edit with valid parameters" do
    given_a_trainee_exists
    when_i_visit_the_programme_details_page
    and_i_enter_valid_parameters
    and_i_submit_the_form
    then_i_am_redirected_to_the_summary_page
    and_the_programme_details_are_updated
  end

  scenario "edit with invalid parameters" do
    given_a_trainee_exists
    when_i_visit_the_programme_details_page
    and_i_submit_the_form
    then_i_see_error_messages
  end

  def given_a_trainee_exists
    @trainee = create(:trainee)
  end

  def when_i_visit_the_programme_details_page
    @programme_details_page ||= PageObjects::Trainees::ProgrammeDetails.new
    @programme_details_page.load(id: @trainee.id)
  end

  def and_i_enter_valid_parameters
    @programme_details_page.subject.select(template.subject)
    @programme_details_page.set_date_fields("programme_start_date", template.programme_start_date.strftime("%d/%m/%Y"))

    age_range = AGE_RANGES.find { |a| a[:name] == template.age_range }

    if age_range[:option] == :main
      @programme_details_page.send("main_age_range_#{template.age_range.parameterize(separator: '_')}").choose
    else
      @programme_details_page.main_age_range_other.choose
      @programme_details_page.additional_age_range.select(template.age_range)
    end
  end

  def and_i_submit_the_form
    @programme_details_page.submit_button.click
  end

  def then_i_am_redirected_to_the_summary_page
    @summary_page ||= PageObjects::Trainees::Summary.new
    expect(@summary_page).to be_displayed(id: @trainee.id)
  end

  def and_the_programme_details_are_updated
    when_i_visit_the_programme_details_page

    expect(@programme_details_page.subject.value).to eq(template.subject)
    expect(@programme_details_page.programme_start_date_day.value).to eq(template.programme_start_date.day.to_s)
    expect(@programme_details_page.programme_start_date_month.value).to eq(template.programme_start_date.month.to_s)
    expect(@programme_details_page.programme_start_date_year.value).to eq(template.programme_start_date.year.to_s)

    age_range = AGE_RANGES.find { |a| a[:name] == template.age_range }

    if age_range[:option] == :main
      expect(@programme_details_page.send("main_age_range_#{template.age_range.parameterize(separator: '_')}")).to be_checked
    else
      expect(@programme_details_page.main_age_range_other).to be_checked
      expect(@programme_details_page.additional_age_range.value).to eq(template.age_range)
    end
  end

  def then_i_see_error_messages
    translation_key_prefix = "activemodel.errors.models.programme_detail.attributes"

    expect(page).to have_content(
      I18n.t("#{translation_key_prefix}.subject.blank"),
    )
    expect(page).to have_content(
      I18n.t("#{translation_key_prefix}.main_age_range.blank"),
    )
    expect(page).to have_content(
      I18n.t("#{translation_key_prefix}.programme_start_date.blank"),
    )
  end

  def template
    @template ||= build(:trainee, :with_programme_details)
  end
end
