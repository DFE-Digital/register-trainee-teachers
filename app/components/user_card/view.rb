# frozen_string_literal: true

module UserCard
  class View < GovukComponent::Base
    with_collection_parameter :user

    attr_reader :user

    def initialize(user:, show_register_button: false, registration_form_path: nil)
      @user = user
      @show_register_button = show_register_button
      @registration_form_path = registration_form_path
    end

    def updated_at
      tag.p("Created at: " + user.created_at.strftime("%-d %B %Y"))
    end

    def email_address
      tag.p("Email address: " + user.email)
    end

    def dttp_id
      return if user.dttp_id.blank?

      tag.p("DTTP ID: " + user.dttp_id)
    end

  private

    attr_reader :show_register_button, :registration_form_path
  end
end
