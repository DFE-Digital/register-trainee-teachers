# frozen_string_literal: true

class SendCsvSubmittedForProcessingFirstStageEmailService
  include ServicePattern
  include Rails.application.routes.url_helpers

  def initialize(upload:)
    @upload = upload
  end

  def call
    upload.provider.users.each do |user|
      CsvSubmittedForProcessingFirstStageEmailMailer.generate(
        upload:,
        user:,
      ).deliver_later(wait: 30.seconds)
    end
  end

private

  attr_reader :upload
end
