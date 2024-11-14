# frozen_string_literal: true

# == Schema Information
#
# Table name: bulk_update_row_errors
#
#  id              :bigint           not null, primary key
#  error_type      :string           default("validation"), not null
#  errored_on_type :string
#  message         :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  errored_on_id   :bigint
#
# Indexes
#
#  index_bulk_update_row_errors_on_error_type  (error_type)
#
class BulkUpdate::RowError < ApplicationRecord
  belongs_to :errored_on, polymorphic: true

  enum :error_type, {
    duplicate: "duplicate",
    validation: "validation",
  }
end
