# frozen_string_literal: true

require "rails_helper"

feature "Filtering trainees" do
  context "registered trainees" do
    before do
      given_i_am_authenticated
      given_registered_trainees_exist_in_the_system
      given_a_subject_specialism_is_available_for_selection
      when_i_visit_the_trainee_index_page
      then_i_see_my_provider_name
      then_all_registered_trainees_are_visible
    end

    context "when filtering trainees by record completion" do
      before do
        given_an_incomplete_hesa_trainee_exists
        given_an_incomplete_withdrawn_trainee_exists
      end

      scenario "can filter by complete records" do
        when_i_filter_by_complete
        then_only_complete_records_are_visible
      end

      scenario "can filter by incomplete records" do
        when_i_filter_by_incomplete
        then_only_incomplete_records_are_visible
      end
    end

    scenario "can filter by subject" do
      when_i_filter_by_subject("Biology")
      then_only_biology_trainees_are_visible
      then_the_tag_is_visible_for("Biology")
      then_the_select_should_still_show("Biology")
      when_i_remove_a_tag_for("Biology")
      then_all_registered_trainees_are_visible
      when_i_filter_by_subject("All subjects")
      then_all_registered_trainees_are_visible
    end

    scenario "can filter by record source" do
      then_the_record_source_filter_is_visible
    end

    scenario "can filter by status" do
      when_i_filter_by_in_training_status
      then_only_the_in_training_trainee_is_visible
    end

    scenario "can filter by multiple statuses" do
      when_i_filter_by_in_training_status
      and_i_filter_by_withdrawn_status
      then_the_in_training_and_withdrawn_trainees_are_visible
    end

    scenario "can filter by level" do
      when_i_filter_by_early_years_level
      then_only_the_early_years_trainee_is_visible
    end

    scenario "can filter by training route" do
      when_i_filter_by_assessment_only
      then_only_assessment_only_trainee_is_visible
    end

    scenario "can clear filters" do
      when_i_filter_by_subject("Biology")
      then_only_biology_trainees_are_visible
      when_i_clear_filters
      then_all_registered_trainees_are_visible
    end

    scenario "no matches" do
      when_i_filter_by_a_subject_which_returns_no_matches
      then_i_see_a_zero_records_found_message
      then_i_should_not_see_sort_links
    end

    scenario "cannot filter by provider" do
      then_i_should_not_see_the_provider_filter
    end

    context "as a system-admin" do
      before do
        given_i_am_authenticated_as_system_admin
        when_i_visit_the_trainee_index_page
      end

      scenario "can filter by provider" do
        then_i_should_see_the_provider_filter
      end

      scenario "can filter by record source" do
        then_i_should_see_record_source_filter
      end

      scenario "when all trainees are from a single source" do
        given_all_trainees_are_from_a_single_source
        when_i_visit_the_trainee_index_page
      end

      scenario "can filter by dttp import as record source" do
        when_i_filter_by_dttp_import
        then_only_the_trainee_imported_from_dttp_is_visible
      end

      scenario "cannot see dttp import filter when dttp trainees do not exist" do
        when_dttp_trainees_do_not_exist
        when_i_visit_the_trainee_index_page
        then_i_should_not_see_imported_from_dttp_as_record_source
      end
    end

    context "searching" do
      before { when_i_search_for(search_term) }

      shared_examples_for "a working search" do
        it "returns the correct trainee" do
          then_only_the_searchable_trainee_is_visible
          then_the_tag_is_visible_for(search_term)
        end
      end

      context "by name" do
        let(:search_term) { @searchable_trainee.first_names }

        it_behaves_like "a working search"
      end

      context "by trn" do
        let(:search_term) { @searchable_trainee.trn }

        it_behaves_like "a working search"
      end

      context "by provider_trainee_id" do
        let(:search_term) { @searchable_trainee.provider_trainee_id }

        it_behaves_like "a working search"
      end
    end

    context "exporting", feature_trainee_export: true do
      scenario "exporting with no filter" do
        and_i_export_the_results
        then_i_see_my_trainee_search_results
      end

      scenario "exporting with a filter" do
        when_i_filter_by_subject("Biology")
        and_i_export_the_results
        then_i_see_my_filtered_trainee_search_results
      end
    end
  end

  context "draft trainees" do
    before do
      given_i_am_authenticated
      given_draft_trainees_exist_in_the_system
      when_i_visit_the_drafts_index_page
      then_i_see_my_provider_name
      then_all_draft_trainees_are_visible
    end

    scenario "can filter by apply_drafts" do
      when_i_filter_by_apply_draft_status
      then_only_the_apply_draft_trainees_are_visible
    end
  end

private

  def given_registered_trainees_exist_in_the_system
    @assessment_only_trainee ||= create(:trainee, :submitted_for_trn, training_route: ReferenceData::TRAINING_ROUTES.assessment_only.name)
    @provider_led_postgrad_trainee ||= create(:trainee, :submitted_for_trn, training_route: ReferenceData::TRAINING_ROUTES.provider_led_postgrad.name)
    @biology_trainee ||= create(:trainee, :submitted_for_trn, :with_subject_specialism, subject_name: CourseSubjects::BIOLOGY)
    @history_trainee ||= create(:trainee, :submitted_for_trn, :with_subject_specialism, subject_name: CourseSubjects::HISTORY)
    @searchable_trainee ||= create(:trainee, :submitted_for_trn, trn: "123")
    @complete_trainee ||= create(:trainee, :completed, :submitted_with_start_date)
    @incomplete_trainee ||= create(:trainee, :submitted_for_trn)
    @trn_received_trainee ||= create(:trainee, :submitted_for_trn, :trn_received)
    @withdrawn_trainee ||= create(:trainee, :withdrawn)
    @early_years_trainee ||= create(:trainee, :submitted_for_trn, :early_years_undergrad)
    @primary_trainee ||= create(:trainee, :submitted_for_trn, course_age_range: DfE::ReferenceData::AgeRanges::THREE_TO_EIGHT)
    @apply_non_draft_trainee ||= create(:trainee, :submitted_for_trn, :with_apply_application)
    @dttp_import_trainee ||= create(:trainee, :submitted_for_trn, :created_from_dttp)
    Trainee.update_all(provider_id: @current_user.organisation.id)
  end

  def given_draft_trainees_exist_in_the_system
    @manual_draft_trainee ||= create(:trainee, provider: current_provider)
    @apply_draft_trainee ||= create(:trainee, :with_apply_application, provider: current_provider)
    @dttp_draft_trainee ||= create(:trainee, :created_from_dttp, provider: current_provider)
  end

  def given_an_incomplete_hesa_trainee_exists
    @incomplete_hesa_trainee ||= create(:trainee, :imported_from_hesa, :submitted_for_trn)
    @incomplete_hesa_trainee.update(trainee_start_date: nil)
    Trainee.update_all(provider_id: @current_user.organisation.id)
  end

  def given_an_incomplete_withdrawn_trainee_exists
    @incomplete_withdrawn_trainee ||= create(:trainee, :submitted_for_trn, :withdrawn)
    @incomplete_withdrawn_trainee.update(trainee_start_date: nil)
    Trainee.update_all(provider_id: @current_user.organisation.id)
  end

  def current_provider
    @current_provider ||= @current_user.organisation
  end

  def given_all_trainees_are_from_a_single_source
    Trainee.with_apply_application.destroy_all
    Trainee.dttp_record.destroy_all
  end

  def then_the_record_source_filter_is_visible
    expect(trainee_index_page).to have_text(I18n.t("activerecord.attributes.trainee.record_sources.manual"))
  end

  def given_a_subject_specialism_is_available_for_selection
    @subject_specialism ||= create(:subject_specialism)
  end

  def when_i_visit_the_trainee_index_page
    trainee_index_page.load
    expect(trainee_index_page).to be_displayed
  end

  def when_i_visit_the_drafts_index_page
    trainee_drafts_page.load
    expect(trainee_drafts_page).to be_displayed
  end

  def when_i_filter_by_assessment_only
    trainee_index_page.assessment_only_checkbox.click
    trainee_index_page.apply_filters.click
  end

  def when_i_filter_by_in_training_status
    trainee_index_page.in_training_checkbox.click
    trainee_index_page.apply_filters.click
  end

  def and_i_filter_by_withdrawn_status
    trainee_index_page.withdrawn_checkbox.click
    trainee_index_page.apply_filters.click
  end

  def when_i_filter_by_apply_draft_status
    trainee_index_page.imported_from_apply_checkbox.click
    trainee_index_page.apply_filters.click
  end

  def when_i_filter_by_dttp_import
    trainee_index_page.imported_from_dttp_checkbox.click
    trainee_index_page.apply_filters.click
  end

  def when_dttp_trainees_do_not_exist
    Trainee.dttp_record.destroy_all
  end

  def when_i_remove_a_tag_for(value)
    click_on(value)
    trainee_index_page.apply_filters.click
  end

  def when_i_filter_by_subject(value)
    trainee_index_page.subject.select(value)
    trainee_index_page.apply_filters.click
  end

  def when_i_filter_by_complete
    trainee_index_page.complete_checkbox.check
    trainee_index_page.apply_filters.click
  end

  def when_i_filter_by_incomplete
    @incomplete_trainee.update(trainee_start_date: nil)
    trainee_index_page.incomplete_checkbox.check
    trainee_index_page.apply_filters.click
  end

  def when_i_filter_by_early_years_level
    trainee_index_page.early_years_checkbox.click
    trainee_index_page.apply_filters.click
  end

  def when_i_search_for(value)
    trainee_index_page.text_search.fill_in(with: value)
    trainee_index_page.apply_filters.click
  end

  def when_i_clear_filters
    trainee_index_page.clear_filters_link.click
  end

  def when_i_filter_by_a_subject_which_returns_no_matches
    when_i_filter_by_subject(@subject_specialism.name.capitalize)
  end

  def then_i_see_a_zero_records_found_message
    expect(trainee_index_page.zero_records_found).to have_text("No records found")
  end

  def then_i_should_not_see_sort_links
    expect(trainee_index_page).not_to have_content("Sort by")
  end

  def then_i_see_my_provider_name
    expect(trainee_index_page).to have_text(current_user.organisation.name)
  end

  def then_the_checkbox_should_still_be_checked_for(value)
    checkbox = trainee_index_page.public_send("#{value}_checkbox")
    expect(checkbox.checked?).to be(true)
  end

  def then_the_select_should_still_show(value)
    select = trainee_index_page.subject
    expect(select.value.upcase_first).to eq value
  end

  def then_all_registered_trainees_are_visible
    Trainee.where.not(state: "draft").find_each { |trainee| expect(trainee_index_page).to have_text(full_name(trainee)) }
  end

  def then_all_draft_trainees_are_visible
    Trainee.draft.each { |trainee| expect(trainee_drafts_page).to have_text(full_name(trainee)) }
  end

  def then_only_biology_trainees_are_visible
    expect(trainee_index_page).to have_text(full_name(@biology_trainee))
    expect(trainee_index_page).not_to have_text(full_name(@history_trainee))
  end

  def then_only_complete_records_are_visible
    expect(trainee_index_page).to have_text(full_name(@complete_trainee)) &
      have_text(full_name(@incomplete_withdrawn_trainee))
  end

  def then_only_incomplete_records_are_visible
    expect(trainee_index_page).to have_text(full_name(@incomplete_trainee))
    expect(trainee_index_page).to have_text(full_name(@incomplete_hesa_trainee))
    expect(trainee_index_page).not_to have_text(full_name(@incomplete_withdrawn_trainee))
  end

  def then_only_the_searchable_trainee_is_visible
    expect(trainee_index_page).to have_text(full_name(@searchable_trainee))
    [
      @assessment_only_trainee,
      @provider_led_postgrad_trainee,
      @history_trainee,
      @biology_trainee,
    ].each do |trainee|
      expect(trainee_index_page).not_to have_text(full_name(trainee))
    end
  end

  def then_only_the_apply_draft_trainees_are_visible
    expect(trainee_drafts_page).to have_text(full_name(@apply_draft_trainee))
  end

  def then_i_should_not_see_imported_from_dttp_as_record_source
    expect(trainee_index_page).not_to have_text("Imported from DTTP")
  end

  def then_i_should_see_record_source_filter
    expect(trainee_index_page).to have_text(I18n.t("components.filter.record_source"))
  end

  def then_only_the_in_training_trainee_is_visible
    expect(trainee_index_page).to have_text(full_name(@trn_received_trainee))
    expect(trainee_index_page).not_to have_text(full_name(@withdrawn_trainee))
  end

  def then_the_in_training_and_withdrawn_trainees_are_visible
    expect(trainee_index_page).to have_text(full_name(@trn_received_trainee))
    expect(trainee_index_page).to have_text(full_name(@withdrawn_trainee))
  end

  def then_only_assessment_only_trainee_is_visible
    expect(trainee_index_page).to have_text(full_name(@assessment_only_trainee))
    expect(trainee_index_page).not_to have_text(full_name(@provider_led_postgrad_trainee))
  end

  def then_only_the_early_years_trainee_is_visible
    expect(trainee_index_page).to have_text(full_name(@early_years_trainee))
    expect(trainee_index_page).not_to have_text(full_name(@primary_trainee))
  end

  def then_the_tag_is_visible_for(*values)
    values.each do |value|
      expect(trainee_index_page.filter_tags).to have_text(value)
    end
  end

  def then_i_should_not_see_the_provider_filter
    expect(trainee_index_page).not_to have_provider_filter
  end

  def then_i_should_see_the_provider_filter
    expect(trainee_index_page).to have_provider_filter
  end

  def then_only_the_trainee_imported_from_dttp_is_visible
    expect(trainee_index_page).to have_text(full_name(@dttp_import_trainee))
    expect(trainee_index_page).not_to have_text(full_name(@apply_non_draft_trainee))
  end

  def full_name(trainee)
    [trainee.first_names, trainee.last_name].join(" ")
  end

  def and_i_export_the_results
    trainee_index_page.export_link.click
  end

  def then_i_see_my_trainee_search_results
    expect(csv_output).to include(@assessment_only_trainee.provider_trainee_id)
    expect(csv_output).to include(@provider_led_postgrad_trainee.provider_trainee_id)
    expect(csv_output).to include(@biology_trainee.provider_trainee_id)
    expect(csv_output).to include(@history_trainee.provider_trainee_id)
  end

  def then_i_see_my_filtered_trainee_search_results
    expect(csv_output).to include(@biology_trainee.provider_trainee_id)

    expect(csv_output).not_to include(@assessment_only_trainee.provider_trainee_id)
    expect(csv_output).not_to include(@provider_led_postgrad_trainee.provider_trainee_id)
    expect(csv_output).not_to include(@searchable_trainee.provider_trainee_id)
    expect(csv_output).not_to include(@history_trainee.provider_trainee_id)
  end

  def csv_output
    @csv_output ||= CSV.parse(trainee_index_page.text).flatten.compact.map(&:strip)
  end
end
