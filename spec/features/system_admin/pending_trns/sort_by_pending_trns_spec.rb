# frozen_string_literal: true

require "rails_helper"

feature "sort by pending TRNs" do
  let!(:trainee_two) { create(:trainee, :submitted_for_trn, :with_dqt_trn_request) }
  let!(:trainee_one) { create(:trainee, :submitted_for_trn, :with_dqt_trn_request) }

  before do
    given_i_am_authenticated_as_system_admin
  end

  context "with multiple jobs ordered by days waiting" do
    before do
      trainee_one.dqt_trn_request.update(created_at: 2.days.ago)
      trainee_two.dqt_trn_request.update(created_at: 1.day.ago)
      and_i_visit_the_pending_awards_page
    end

    it "sorts trainees correctly" do
      expect(admin_pending_trns_page.sort_by).not_to have_link "Days waiting" # page will default to day waiting
      expect(admin_pending_trns_page.sort_by).to have_link "Register"

      expect(admin_pending_trns_page.accordian.items.first).to have_text trainee_one.last_name
      expect(admin_pending_trns_page.accordian.items.last).to have_text trainee_two.last_name
    end
  end

  context "with multiple jobs ordered by register id" do
    let!(:trainee_two) { create(:trainee, :submitted_for_trn, :with_dqt_trn_request, id: 20000) }
    let!(:trainee_one) { create(:trainee, :submitted_for_trn, :with_dqt_trn_request, id: 10000) }

    before do
      and_i_visit_the_pending_awards_page
      admin_pending_trns_page.sort_by.register_id.click
    end

    it "sorts trainees correctly" do
      expect(admin_pending_trns_page.sort_by).to have_link "Days waiting"
      expect(admin_pending_trns_page.sort_by).not_to have_link "Register"

      expect(admin_pending_trns_page.accordian.items.first).to have_text trainee_one.last_name
      expect(admin_pending_trns_page.accordian.items.last).to have_text trainee_two.last_name
    end
  end

  def and_i_visit_the_pending_awards_page
    admin_pending_trns_page.load
  end
end
