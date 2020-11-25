# frozen_string_literal: true

class DfESignInUser
  attr_reader :email, :dfe_sign_in_uid
  attr_accessor :first_name, :last_name

  def initialize(email:, dfe_sign_in_uid:, first_name:, last_name:, id_token: nil)
    @email = email&.downcase
    @dfe_sign_in_uid = dfe_sign_in_uid
    @first_name = first_name
    @last_name = last_name
    @id_token = id_token
  end

  def self.begin_session!(session, omniauth_payload)
    session["dfe_sign_in_user"] = {
      "email" => omniauth_payload["info"]["email"],
      "dfe_sign_in_uid" => omniauth_payload["uid"],
      "first_name" => omniauth_payload["info"]["first_name"],
      "last_name" => omniauth_payload["info"]["last_name"],
      "last_active_at" => Time.zone.now,
      "id_token" => omniauth_payload["credentials"]["id_token"],
    }
  end

  def self.load_from_session(session)
    dfe_sign_in_session = session["dfe_sign_in_user"]
    return unless dfe_sign_in_session

    # Users who signed in before session expiry was implemented will not have
    # `last_active_at` set. In that case, force them to sign in again.
    return unless dfe_sign_in_session["last_active_at"]

    return if dfe_sign_in_session.fetch("last_active_at") < 2.hours.ago

    dfe_sign_in_session["last_active_at"] = Time.zone.now

    new(
      email: dfe_sign_in_session["email"],
      dfe_sign_in_uid: dfe_sign_in_session["dfe_sign_in_uid"],
      first_name: dfe_sign_in_session["first_name"],
      last_name: dfe_sign_in_session["last_name"],
      id_token: dfe_sign_in_session["id_token"],
    )
  end

  def self.end_session!(session)
    session.delete("dfe_sign_in_user")
  end
end
