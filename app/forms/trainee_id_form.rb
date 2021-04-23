# frozen_string_literal: true

class TraineeIdForm < TraineeForm
  attr_accessor :trainee_id

  validates :trainee_id, presence: true

  def save!
    if valid?
      update_trainee_id
      trainee.save!
      clear_stash
    else
      false
    end
  end

private

  def compute_fields
    trainee.attributes.symbolize_keys.slice(:trainee_id).merge(new_attributes)
  end

  def update_trainee_id
    trainee.assign_attributes(trainee_id: trainee_id) if errors.empty?
  end
end
