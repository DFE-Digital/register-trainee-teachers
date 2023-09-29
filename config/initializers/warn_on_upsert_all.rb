# frozen_string_literal: true

module WarnOnUpsertAll
  def upsert_all(*args, **kwargs)
    unless File.basename($PROGRAM_NAME) == "rake" && ARGV.include?("db:seed")
      Rails.logger.warn("WARNING: Please consider using `BulkUpdate::InsertAll` service for bulk insert operations to ensure that BigQuery and Audit events are triggered.")
    end
    super(*args, **kwargs)
  end
end

ActiveSupport.on_load(:active_record) { extend WarnOnUpsertAll }
