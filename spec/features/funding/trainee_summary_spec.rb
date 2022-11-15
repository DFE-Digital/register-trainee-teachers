# frozen_string_literal: true

require "rails_helper"

feature "viewing the trainee summary", feature_funding: true do
  let(:user) { create(:user) }
  let(:test_subject) { "Test subject" }

  background {
    Rails.application.reload_routes!
    given_i_am_authenticated(user: user)
  }

  context "with a trainee summary in the current academic year" do
    let(:summary) { create(:trainee_summary, payable: user.providers.first) }
    let(:row) { create(:trainee_summary_row, trainee_summary: summary, subject: test_subject) }

    context "an organisation with bursary data" do
      background {
        create(:trainee_summary_row_amount, :with_bursary, row: row)
        when_i_visit_the_trainee_summary_page
      }
      scenario "displays the bursary breakdown table" do
        then_i_see_the_bursary_table
      end

      scenario "displays the summary table" do
        then_i_see_the_summary_table
      end

      scenario "downloads trainee summary export csv" do
        and_i_export_the_results
        then_i_see_my_exported_data_in_csv_format
      end
    end

    context "bursary rows with zero totals" do
      background {
        create(:trainee_summary_row_amount, :with_bursary, row: row, number_of_trainees: number_of_trainees, amount_in_pence: amount_in_pence)
        when_i_visit_the_trainee_summary_page
      }

      context "a bursary subject amount but no trainees" do
        let(:amount_in_pence) { 10000 }
        let(:number_of_trainees) { 0 }

        scenario "doesn't display the row in the table" do
          then_i_do_not_see_the_row_in_the_table
        end
      end

      context "trainees but no bursary amount" do
        let(:amount_in_pence) { 0 }
        let(:number_of_trainees) { 5 }

        scenario "doesn't display the row in the table" do
          then_i_do_not_see_the_row_in_the_table
        end
      end
    end

    context "an organisation with scholarship data" do
      background {
        create(:trainee_summary_row_amount, :with_scholarship, row: row)
        when_i_visit_the_trainee_summary_page
      }
      scenario "displays the scholarship breakdown table" do
        then_i_see_the_scholarship_table
      end
    end

    context "scholarship rows with zero totals" do
      background {
        create(:trainee_summary_row_amount, :with_scholarship, row: row, number_of_trainees: number_of_trainees, amount_in_pence: amount_in_pence)
        when_i_visit_the_trainee_summary_page
      }

      context "a scholarship subject amount but no trainees" do
        let(:amount_in_pence) { 10000 }
        let(:number_of_trainees) { 0 }

        scenario "doesn't display the row in the table" do
          then_i_do_not_see_the_row_in_the_table
        end
      end

      context "trainees but no scholarship amount" do
        let(:amount_in_pence) { 0 }
        let(:number_of_trainees) { 5 }

        scenario "doesn't display the row in the table" do
          then_i_do_not_see_the_row_in_the_table
        end
      end
    end

    context "an organisation with tiered bursary data" do
      background {
        create(:trainee_summary_row_amount, :with_tiered_bursary, row: row)
        when_i_visit_the_trainee_summary_page
      }
      scenario "displays the tiered bursary breakdown table" do
        then_i_see_the_tiered_bursary_table
      end
    end

    context "tiered bursary rows with zero totals" do
      let(:tier) { 3 }

      background {
        create(:trainee_summary_row_amount, :with_tiered_bursary, row: row, tier: tier, number_of_trainees: number_of_trainees, amount_in_pence: amount_in_pence)
        when_i_visit_the_trainee_summary_page
      }

      context "a tiered bursary subject amount but no trainees" do
        let(:amount_in_pence) { 10000 }
        let(:number_of_trainees) { 0 }

        scenario "doesn't display the row in the table" do
          then_i_do_not_see_the_tiered_bursary_row_in_the_table
        end
      end

      context "trainees but no tiered bursary amount" do
        let(:amount_in_pence) { 0 }
        let(:number_of_trainees) { 5 }

        scenario "doesn't display the row in the table" do
          then_i_do_not_see_the_tiered_bursary_row_in_the_table
        end
      end
    end

    context "an organisation with grant data" do
      background {
        create(:trainee_summary_row_amount, :with_grant, row: row)
        when_i_visit_the_trainee_summary_page
      }
      scenario "displays the grant breakdown table" do
        then_i_see_the_grant_table
      end
    end

    context "grant rows with zero totals" do
      background {
        create(:trainee_summary_row_amount, :with_grant, row: row, number_of_trainees: number_of_trainees, amount_in_pence: amount_in_pence)
        when_i_visit_the_trainee_summary_page
      }

      context "a grant subject amount but no trainees" do
        let(:amount_in_pence) { 10000 }
        let(:number_of_trainees) { 0 }

        scenario "doesn't display the row in the table" do
          then_i_do_not_see_the_row_in_the_table
        end
      end

      context "trainees but no grant amount" do
        let(:amount_in_pence) { 0 }
        let(:number_of_trainees) { 5 }

        scenario "doesn't display the row in the table" do
          then_i_do_not_see_the_row_in_the_table
        end
      end
    end
  end

  context "with a valid trainee summary in the previous academic year" do
    let(:academic_year) { AcademicCycle.current }
    let(:previous_academic_year_string) { "#{academic_year.start_date.year - 1}/#{(academic_year.end_date.year - 1) % 100}" }
    let(:summary) { create(:trainee_summary, payable: user.providers.first, academic_year: previous_academic_year_string) }
    let(:row) { create(:trainee_summary_row, trainee_summary: summary, subject: test_subject) }
    let!(:amount) { create(:trainee_summary_row_amount, :with_bursary, row: row) }

    scenario "displays the empty state" do
      when_i_visit_the_trainee_summary_page
      then_i_see_the_empty_state
    end
  end

  context "organisation without a trainee summary" do
    context "with rows but no amounts" do
      let(:summary) { create(:trainee_summary, payable: user.providers.first) }
      let!(:row) { create(:trainee_summary_row, trainee_summary: summary) }

      scenario "displays the empty state" do
        when_i_visit_the_trainee_summary_page
        then_i_see_the_empty_state
      end
    end

    context "with trainee summary nil" do
      scenario "displays the empty state" do
        when_i_visit_the_trainee_summary_page
        then_i_see_the_empty_state
      end
    end
  end

private

  def when_i_visit_the_trainee_summary_page
    trainee_summary_page.load
  end

  def then_i_see_the_bursary_table
    expect(trainee_summary_page). to have_text("ITT bursaries")
  end

  def then_i_see_the_summary_table
    expect(trainee_summary_page). to have_text("Summary")
  end

  def then_i_see_the_scholarship_table
    expect(trainee_summary_page). to have_text("ITT scholarships")
  end

  def then_i_see_the_tiered_bursary_table
    expect(trainee_summary_page). to have_text("Early years ITT bursaries")
  end

  def then_i_see_the_grant_table
    expect(trainee_summary_page). to have_text("Grants")
  end

  def then_i_see_the_empty_state
    expect(trainee_summary_page). to have_text("There are no trainee summaries available")
  end

  def then_i_do_not_see_the_row_in_the_table
    expect(trainee_summary_page). not_to have_text(test_subject)
  end

  def then_i_do_not_see_the_tiered_bursary_row_in_the_table
    expect(trainee_summary_page). not_to have_text("Tier #{tier}")
  end

  def and_i_export_the_results
    trainee_summary_page.export_link.click
  end

  def then_i_see_my_exported_data_in_csv_format
    expect(csv_data).to include("Funding type,Route,Course,Lead school,Tier,Number of trainees,Amount per trainee,Total")
    expect(csv_data).to include("bursary")
    expect(csv_data).to include(row.route)
    expect(csv_data).to include(row.subject)
    expect(csv_data).to include(row.lead_school_name)
    expect(csv_data).to include("Not applicable")
    expect(csv_data).to include(row.amounts.first.number_of_trainees.to_s)
    expect(csv_data).to include(to_pounds(row.amounts.first.amount_in_pence))
    expect(csv_data).to include(to_pounds(row.amounts.first.number_of_trainees * row.amounts.first.amount_in_pence))
  end

  def csv_data
    @csv_data ||= trainee_summary_page.text
  end

  def to_pounds(value_in_pence)
    ActionController::Base.helpers.number_to_currency(value_in_pence.to_d / 100, unit: "£")
  end
end
