# frozen_string_literal: true

# == Schema Information
#
# Table name: potential_duplicate_trainees
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :uuid             not null
#  trainee_id :bigint           not null
#
# Indexes
#
#  index_potential_duplicate_trainees_on_group_id    (group_id)
#  index_potential_duplicate_trainees_on_trainee_id  (trainee_id)
#
# Foreign Keys
#
#  fk_rails_...  (trainee_id => trainees.id)
#
class PotentialDuplicateTrainee < ApplicationRecord
  belongs_to :trainee
end
