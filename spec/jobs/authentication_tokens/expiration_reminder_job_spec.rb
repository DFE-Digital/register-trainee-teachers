# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuthenticationTokens::ExpirationReminderJob do
  subject { described_class }

  describe "#perform" do
    let!(:token_should_have_expired_in_the_past) { create(:authentication_token, expires_at: 1.day.ago) }
    let!(:token_wont_expire) { create(:authentication_token, expires_at: 3.months.from_now) }
    let!(:token_expired) { create(:authentication_token, :expired) }
    let!(:token_revoked) { create(:authentication_token, :revoked) }

    let!(:token_will_expire_today) { create(:authentication_token, expires_at: Date.current) }
    let!(:token_will_expire_tomorrow) { create(:authentication_token, expires_at: Date.tomorrow) }
    let!(:token_will_expire_in_one_month) { create(:authentication_token, expires_at: 1.month.from_now) }
    let!(:token_will_expire_in_two_months) { create(:authentication_token, expires_at: 2.months.from_now) }
    let!(:token_will_expire_in_one_week) { create(:authentication_token, expires_at: 1.week.from_now) }
    let!(:token_will_expire_in_two_weeks) { create(:authentication_token, expires_at: 2.weeks.from_now) }

    it "enqueues emails only for active tokens" do
      expect { subject.perform_now }
        .to have_enqueued_mail(AuthenticationTokens::ExpirationReminderMailer, :generate)
        .with(authentication_token: token_will_expire_tomorrow)
        .and have_enqueued_mail(AuthenticationTokens::ExpirationReminderMailer, :generate)
        .with(authentication_token: token_will_expire_in_one_week)
        .and have_enqueued_mail(AuthenticationTokens::ExpirationReminderMailer, :generate)
        .with(authentication_token: token_will_expire_in_one_month)
        .and have_enqueued_mail(AuthenticationTokens::ExpirationReminderMailer, :generate).exactly(3).times
    end
  end
end
