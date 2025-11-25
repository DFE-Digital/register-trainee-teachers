# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuthenticationTokens::ExpireTokensJob do
  subject { described_class }

  describe "#perform" do
    let!(:token_will_expire_today) { create(:authentication_token, expires_at: Date.current) }
    let!(:token_should_have_expired_in_the_past) { create(:authentication_token, expires_at: 1.day.ago) }
    let!(:token_will_expire_in_the_future) { create(:authentication_token) }
    let!(:token_wont_expire) { create(:authentication_token) }
    let!(:token_expired) { create(:authentication_token, :expired) }
    let!(:token_revoked) { create(:authentication_token, :revoked) }

    it do
      expect {
        subject.perform_now
      }.to change {
        token_will_expire_today.reload.status
      }.from("active").to("expired")
        .and change {
          token_should_have_expired_in_the_past.reload.status
        }.from("active").to("expired")
        .and not_change {
          token_will_expire_in_the_future.reload.status
        }
        .and not_change {
          token_wont_expire.reload.status
        }
        .and not_change {
          token_expired.reload.status
        }
        .and not_change {
          token_revoked.reload.status
        }
    end
  end
end
