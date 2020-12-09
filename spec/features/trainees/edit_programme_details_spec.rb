# frozen_string_literal: true

require "rails_helper"

feature "programme details", type: :feature do
  background do
    given_i_am_authenticated
    given_a_trainee_exists
  end

  describe "tracking the progress" do
    scenario "renders a 'not started' status when no details provided" do
      summary_page.load(id: trainee.id)
      and_the_section_should_be(:not_started)
    end

    scenario "renders an 'in progress' status when details partially provided" do
      when_i_visit_the_programme_details_page
      and_i_enter_valid_parameters
      and_i_submit_the_form
      and_i_confirm_my_details(checked: false, section: programme_details_section)
      then_i_am_redirected_to_the_summary_page
      and_the_section_should_be(:in_progress)
    end

    scenario "renders a completed status when valid details provided" do
      when_i_visit_the_programme_details_page
      and_i_enter_valid_parameters
      and_i_submit_the_form
      and_i_confirm_my_details(section: programme_details_section)
      then_i_am_redirected_to_the_summary_page
      and_the_section_should_be(:completed)
    end
  end

  describe "editing the programme details" do
    scenario "submitting with valid parameters" do
      when_i_visit_the_programme_details_page
      and_i_enter_valid_parameters
      and_i_submit_the_form
      and_i_confirm_my_details(checked: false, section: programme_details_section)
      then_i_am_redirected_to_the_summary_page
      and_the_programme_details_are_updated
    end

    scenario "submitting with invalid parameters" do
      when_i_visit_the_programme_details_page
      and_i_submit_the_form
      then_i_see_error_messages
    end
  end

  def when_i_visit_the_programme_details_page
    @programme_details_page ||= PageObjects::Trainees::ProgrammeDetails.new
    @programme_details_page.load(id: trainee.id)
  end

  def and_i_enter_valid_parameters
    @programme_details_page.subject.select(template.subject)
    @programme_details_page.set_date_fields("programme_start_date", template.programme_start_date.strftime("%d/%m/%Y"))
    @programme_details_page.set_date_fields("programme_end_date", template.programme_end_date.strftime("%d/%m/%Y"))
    age_range = Dttp::CodeSets::AgeRanges::MAPPING[template.age_range]

    if age_range[:option] == :main
      @programme_details_page.public_send("main_age_range_#{template.age_range.parameterize(separator: '_')}").choose
    else
      @programme_details_page.main_age_range_other.choose
      @programme_details_page.additional_age_range.select(template.age_range)
    end
  end

  def and_i_submit_the_form
    @programme_details_page.submit_button.click
  end

  def and_i_visit_the_summary_page
    summary_page.load(id: trainee.id)
  end

  def then_i_am_redirected_to_the_summary_page
    expect(summary_page).to be_displayed(id: trainee.id)
  end

  def and_the_programme_details_are_updated
    when_i_visit_the_programme_details_page

    expect(@programme_details_page.subject.value).to eq(template.subject)
    expect(@programme_details_page.programme_start_date_day.value).to eq(template.programme_start_date.day.to_s)
    expect(@programme_details_page.programme_start_date_month.value).to eq(template.programme_start_date.month.to_s)
    expect(@programme_details_page.programme_start_date_year.value).to eq(template.programme_start_date.year.to_s)
    expect(@programme_details_page.programme_end_date_day.value).to eq(template.programme_end_date.day.to_s)
    expect(@programme_details_page.programme_end_date_month.value).to eq(template.programme_end_date.month.to_s)
    expect(@programme_details_page.programme_end_date_year.value).to eq(template.programme_end_date.year.to_s)

    age_range = Dttp::CodeSets::AgeRanges::MAPPING[template.age_range]

    if age_range[:option] == :main
      expect(@programme_details_page.public_send("main_age_range_#{template.age_range.parameterize(separator: '_')}")).to be_checked
    else
      expect(@programme_details_page.main_age_range_other).to be_checked
      expect(@programme_details_page.additional_age_range.value).to eq(template.age_range)
    end
  end

  def and_the_section_should_be(status)
    expect(summary_page.programme_details.status.text).to eq(Progress::STATUSES[status])
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

  def then_i_am_redirected_to_the_confirm_page
    expect(confirm_details_page).to be_displayed(id: trainee.id, section: programme_details_section)
  end

private

  def programme_details_section
    "programme-details"
  end
end
