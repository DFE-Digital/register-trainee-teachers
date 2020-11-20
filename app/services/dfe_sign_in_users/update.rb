# frozen_string_literal: true

module DfESignInUsers
  class Update
    attr_reader :user, :successful

    alias_method :successful?, :successful

    class << self
      def call(**args)
        new(**args).call
      end
    end

    def initialize(user:, dfe_sign_in_user:)
      @user = user

      attributes = {
        last_signed_in_at: Time.zone.now,
        email: dfe_sign_in_user.email,
        dfe_sign_in_uid: dfe_sign_in_user.dfe_sign_in_uid,
      }

      attributes[:first_name] = dfe_sign_in_user.first_name if dfe_sign_in_user.first_name.present?
      attributes[:last_name] = dfe_sign_in_user.last_name if dfe_sign_in_user.last_name.present?

      @user.assign_attributes(attributes)
    end

    def call
      @successful = user.valid? && user.save!

      self
    end
  end
end
