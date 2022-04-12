class FundingController < ApplicationController
  def index
    payment_profile = current_user.organisation.payment_profiles.order(:created_at).last
    @payment_profile_view = PaymentProfileView.new(payment_profile: payment_profile)
  end
end
