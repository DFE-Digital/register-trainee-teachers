# frozen_string_literal: true

require "rails_helper"

feature "Sorting sidekiq dead jobs" do
  let(:user) { create(:user, system_admin: true) }
  let(:dead_jobs_data) do
    [
      OpenStruct.new(
        item: {
          wrapped: "Trs::UpdateTraineeJob",
          args:
          [
            {
              arguments: [
                { _aj_globalid: "gid://register-trainee-teachers/Trainee/#{trainee_one.id}" },
              ],
            },
          ],
          error_message: 'status: 400, body: {"title":"Teacher has no incomplete ITT record","status":400,"errorCode":10005}, headers: ',
          jid: "1234",
          enqueued_at: 71.hours.ago.to_i,
        }.with_indifferent_access,
      ),
      OpenStruct.new(
        item: {
          wrapped: "Trs::UpdateTraineeJob",
          args:
          [
            {
              arguments: [
                { trainee: { _aj_globalid: "gid://register-trainee-teachers/Trainee/#{trainee_two.id}" } },
              ],
            },
          ],
          error_message: 'status: 400, body: {"title":"Teacher has no incomplete ITT record","status":400,"errorCode":10005}, headers: ',
          jid: "1234",
          enqueued_at: 70.hours.ago.to_i,
        }.with_indifferent_access,
      ),
    ]
  end

  before do
    given_i_am_authenticated(user:)
    and_dead_jobs_exist
    and_i_visit_the_dead_jobs_trs_update_trainee_page
  end

  context "with multiple jobs ordered by days waiting" do
    let(:trainee_one) { create(:trainee, :trn_received) }
    let(:trainee_two) { create(:trainee, :trn_received) }

    it "sorts dead jobs correctly" do
      expect(admin_dead_jobs_trs_update_trainee.sort_by).not_to have_link "Days waiting" # page will default to day waiting
      expect(admin_dead_jobs_trs_update_trainee.sort_by).to have_link "TRN"
      expect(admin_dead_jobs_trs_update_trainee.sort_by).to have_link "Register"

      expect(admin_dead_jobs_trs_update_trainee.dead_jobs_table.first).to have_text trainee_one.full_name
      expect(admin_dead_jobs_trs_update_trainee.dead_jobs_table.last).to have_text trainee_two.full_name
    end
  end

  context "with multiple jobs ordered by register id" do
    let(:trainee_one) { create(:trainee, trn: "000001") }
    let(:trainee_two) { create(:trainee, trn: "000002") }

    before { admin_dead_jobs_trs_update_trainee.sort_by.trn.click }

    it "sorts dead jobs correctly" do
      expect(admin_dead_jobs_trs_update_trainee.sort_by).to have_link "Days waiting"
      expect(admin_dead_jobs_trs_update_trainee.sort_by).not_to have_link "TRN"
      expect(admin_dead_jobs_trs_update_trainee.sort_by).to have_link "Register"

      expect(admin_dead_jobs_trs_update_trainee.dead_jobs_table.first).to have_text trainee_one.full_name
      expect(admin_dead_jobs_trs_update_trainee.dead_jobs_table.last).to have_text trainee_two.full_name
    end
  end

  context "with multiple jobs ordered by TRN" do
    let(:trainee_one) { create(:trainee, :trn_received, id: 1000) }
    let(:trainee_two) { create(:trainee, :trn_received, id: 2000) }

    before { admin_dead_jobs_trs_update_trainee.sort_by.register_id.click }

    it "sorts dead jobs correctly" do
      expect(admin_dead_jobs_trs_update_trainee.sort_by).to have_link "Days waiting"
      expect(admin_dead_jobs_trs_update_trainee.sort_by).to have_link "TRN"
      expect(admin_dead_jobs_trs_update_trainee.sort_by).not_to have_link "Register"

      expect(admin_dead_jobs_trs_update_trainee.dead_jobs_table.first).to have_text trainee_one.full_name
      expect(admin_dead_jobs_trs_update_trainee.dead_jobs_table.last).to have_text trainee_two.full_name
    end
  end

  def and_i_visit_the_dead_jobs_trs_update_trainee_page
    admin_dead_jobs_trs_update_trainee.load
  end

  def and_dead_jobs_exist
    allow(Sidekiq::DeadSet).to receive(:new).and_return(dead_jobs_data)
  end
end
