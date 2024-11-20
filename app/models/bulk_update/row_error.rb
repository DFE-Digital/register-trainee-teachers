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
#  idx_on_errored_on_id_errored_on_type_492045ed60  (errored_on_id,errored_on_type)
#  index_bulk_update_row_errors_on_error_type       (error_type)
#
class BulkUpdate::RowError < ApplicationRecord
  belongs_to :errored_on, polymorphic: true

  enum :error_type, {
    duplicate: "duplicate",
    validation: "validation",
  }
end
