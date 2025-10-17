# frozen_string_literal: true

require "rails_helper"

feature "sort by pending awards" do
  let!(:trainee_two) { create(:trainee, :recommended_for_award, recommended_for_award_at: 1.day.ago) }
  let!(:trainee_one) { create(:trainee, :recommended_for_award, recommended_for_award_at: 2.days.ago) }

  before do
    allow(Trs::FindDeadJobs).to receive(:call).and_return({})
    allow(Trs::FindRetryJobs).to receive(:call).and_return({})
    given_i_am_authenticated_as_system_admin
    and_i_visit_the_pending_awards_page
  end

  context "with multiple jobs ordered by days waiting" do
    it "sorts trainees correctly" do
      expect(admin_pending_awards_page.sort_by).not_to have_link "Days waiting" # page will default to day waiting
      expect(admin_pending_awards_page.sort_by).to have_link "TRN"
      expect(admin_pending_awards_page.sort_by).to have_link "Register"

      expect(admin_pending_awards_page.table.first).to have_text trainee_one.last_name
      expect(admin_pending_awards_page.table.last).to have_text trainee_two.last_name
    end
  end

  context "with multiple jobs ordered by TRN" do
    let(:trn) { Faker::Number.number(digits: 6) }
    let!(:trainee_two) { create(:trainee, :recommended_for_award, trn: trn + 1) }
    let!(:trainee_one) { create(:trainee, :recommended_for_award, trn:) }

    before { admin_pending_awards_page.sort_by.trn.click }

    it "sorts trainees correctly" do
      expect(admin_pending_awards_page.sort_by).to have_link "Days waiting"
      expect(admin_pending_awards_page.sort_by).not_to have_link "TRN"
      expect(admin_pending_awards_page.sort_by).to have_link "Register"

      expect(admin_pending_awards_page.table.first).to have_text trainee_one.last_name
      expect(admin_pending_awards_page.table.last).to have_text trainee_two.last_name
    end
  end

  context "with multiple jobs ordered by Register ID" do
    let(:id) { Faker::Number.number(digits: 5) }
    let!(:trainee_two) { create(:trainee, :recommended_for_award, id: id + 1) }
    let!(:trainee_one) { create(:trainee, :recommended_for_award, id:) }

    before do
      admin_pending_awards_page.sort_by.register_id.click
    end

    it "sorts trainees correctly" do
      expect(admin_pending_awards_page.sort_by).to have_link "Days waiting"
      expect(admin_pending_awards_page.sort_by).to have_link "TRN"
      expect(admin_pending_awards_page.sort_by).not_to have_link "Register"

      expect(admin_pending_awards_page.table.first).to have_text trainee_one.last_name
      expect(admin_pending_awards_page.table.last).to have_text trainee_two.last_name
    end
  end

  def and_i_visit_the_pending_awards_page
    admin_pending_awards_page.load
  end
end
