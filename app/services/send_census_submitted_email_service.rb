# frozen_string_literal: true

class SendCensusSubmittedEmailService
  include ServicePattern

  def initialize(provider:, submitted_at:)
    @provider = provider
    @submitted_at = submitted_at
  end

  def call
    provider.users.kept.each do |user|
      CensusSubmittedEmailMailer.generate(
        user:,
        submitted_at:,
      ).deliver_later
    end
  end

private

  attr_reader :provider, :submitted_at
end
