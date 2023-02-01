# frozen_string_literal: true

# == Schema Information
#
# Table name: trainee_disabilities
#
#  id                    :bigint           not null, primary key
#  additional_disability :text
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  disability_id         :bigint           not null
#  trainee_id            :bigint           not null
#
# Indexes
#
#  index_trainee_disabilities_on_disability_id                 (disability_id)
#  index_trainee_disabilities_on_disability_id_and_trainee_id  (disability_id,trainee_id) UNIQUE
#  index_trainee_disabilities_on_trainee_id                    (trainee_id)
#
# Foreign Keys
#
#  fk_rails_...  (disability_id => disabilities.id)
#  fk_rails_...  (trainee_id => trainees.id)
#
class TraineeDisability < ApplicationRecord
  belongs_to :disability
  belongs_to :trainee, touch: true

  audited associated_with: :trainee

  auto_strip_attributes :additional_disability
end
