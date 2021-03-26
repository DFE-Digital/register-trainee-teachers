class ConsistencyCheck < ApplicationRecord
  validates :trainee_id, presence: true
  validates :contact_last_updated_at, presence: true, uniqueness: { scope: :trainee_id }
end
