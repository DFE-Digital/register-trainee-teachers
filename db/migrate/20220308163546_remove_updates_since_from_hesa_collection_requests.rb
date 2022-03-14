# frozen_string_literal: true

class RemoveUpdatesSinceFromHesaCollectionRequests < ActiveRecord::Migration[6.1]
  def change
    remove_column :hesa_collection_requests, :updates_since, :datetime
  end
end
