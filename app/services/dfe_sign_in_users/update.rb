# frozen_string_literal: true

module DfESignInUsers
  class Update
    include ServicePattern

    attr_reader :user, :successful

    alias_method :successful?, :successful

    def initialize(user:, sign_in_user:)
      @user = user

      attributes = {
        last_signed_in_at: Time.zone.now,
        email: sign_in_user.email,
        dfe_sign_in_uid: sign_in_user.dfe_sign_in_uid,
      }

      attributes[:first_name] = sign_in_user.first_name if sign_in_user.first_name.present?
      attributes[:last_name] = sign_in_user.last_name if sign_in_user.last_name.present?

      @user.assign_attributes(attributes)
    end

    def call
      @successful = user.valid? && user.save!

      self
    end
  end
end
