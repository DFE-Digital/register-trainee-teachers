# frozen_string_literal: true

module ParseAddTraineeCsv
  extend ActiveSupport::Concern

  def convert_to_case_sensitive(header)
    BulkUpdate::AddTrainees::VERSION::ImportRows::CASE_INSENSITIVE_ALL_HEADERS[header.downcase] || header
  end
end
