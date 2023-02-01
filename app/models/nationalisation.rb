# frozen_string_literal: true

# == Schema Information
#
# Table name: nationalisations
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  nationality_id :bigint           not null
#  trainee_id     :bigint           not null
#
# Indexes
#
#  index_nationalisations_on_nationality_id  (nationality_id)
#  index_nationalisations_on_trainee_id      (trainee_id)
#
# Foreign Keys
#
#  fk_rails_...  (nationality_id => nationalities.id)
#  fk_rails_...  (trainee_id => trainees.id)
#
class Nationalisation < ApplicationRecord
  belongs_to :nationality
  belongs_to :trainee, touch: true

  audited associated_with: :trainee
end
