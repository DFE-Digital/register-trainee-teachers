# frozen_string_literal: true

class SendCsvSubmittedForProcessingEmailService
  include ServicePattern
  include Rails.application.routes.url_helpers

  def initialize(upload:)
    @upload = upload
  end

  def call
    CsvSubmittedForProcessingEmailMailer.generate(
      upload:,
    ).deliver_later(wait: 30.seconds)
  end

private

  attr_reader :upload
end
