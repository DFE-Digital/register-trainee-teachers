class AddStateToHesaCollectionRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :hesa_collection_requests, :state, :integer, default: 0
  end
end
