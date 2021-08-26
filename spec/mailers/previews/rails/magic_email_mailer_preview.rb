# frozen_string_literal: true

class MagicEmailMailerPreview < ActionMailer::Preview
  def magic_email
    MagicEmailMailer.magic_email(
      user: FactoryBot.build_stubbed(:user),
      token: "ABC-FOO",
    )
  end
end
