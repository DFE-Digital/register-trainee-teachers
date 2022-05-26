# frozen_string_literal: true

require "rails_helper"

feature "viewing the trainee summary", feature_funding: true do
  let(:user) { create(:user) }
  let(:test_subject) { "Test subject" }

  background {
    Rails.application.reload_routes!
    given_i_am_authenticated(user: user)
    create(:academic_cycle, :current)
  }

  context "with a trainee summary" do
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
    expect(trainee_summary_page). to have_text("There are no trainees eligible")
  end

  def then_i_do_not_see_the_row_in_the_table
    expect(trainee_summary_page). not_to have_text(test_subject)
  end

  def then_i_do_not_see_the_tiered_bursary_row_in_the_table
    expect(trainee_summary_page). not_to have_text("Tier #{tier}")
  end
end
