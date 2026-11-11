# frozen_string_literal: true

module DfESignInUsers
  class Update
    include ServicePattern

    attr_reader :user, :successful

    alias_method :successful?, :successful

    def initialize(user:, sign_in_user:)
      @user = user
      @sign_in_user = sign_in_user
      @email_changed = email_changed?

      attributes = {
        last_signed_in_at: Time.zone.now,
        email: sign_in_user.email,
      }

      attributes[:dfe_sign_in_uid] = sign_in_user.dfe_sign_in_uid if user.dfe_sign_in_uid.blank?
      attributes[:first_name] = sign_in_user.first_name if sign_in_user.first_name.present?
      attributes[:last_name] = sign_in_user.last_name if sign_in_user.last_name.present?

      @user.assign_attributes(attributes)
    end

    def call
      @successful = user.valid? && user.save!

      log_email_change if successful? && @email_changed

      self
    end

  private

    attr_reader :sign_in_user

    def email_changed?
      return false if sign_in_user.email.blank?

      user.email.downcase != sign_in_user.email.downcase
    end

    def log_email_change
      Rails.logger.info("DSI sign-in: email updated for user_id=#{user.id}")
    end
  end
end
