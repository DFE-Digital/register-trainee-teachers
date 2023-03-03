# == Schema Information
#
# Table name: bulk_update_row_errors
#
#  id              :bigint           not null, primary key
#  errored_on_type :string
#  message         :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  errored_on_id   :bigint
#
class BulkUpdate::RowError < ApplicationRecord
  belongs_to :errored_on, polymorphic: true
end
