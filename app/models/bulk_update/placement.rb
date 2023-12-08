# frozen_string_literal: true

# == Schema Information
#
# Table name: bulk_update_placements
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  provider_id :bigint           not null
#
# Indexes
#
#  index_bulk_update_placements_on_provider_id  (provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#
class BulkUpdate::Placement < ApplicationRecord
  belongs_to :provider
  has_one_attached :file, dependent: :purge_later
  has_many :placement_rows,
           class_name: "BulkUpdate::PlacementRow",
           foreign_key: :bulk_update_placement_id,
           dependent: :destroy,
           inverse_of: :bulk_update_placement

  alias rows placement_rows
end
