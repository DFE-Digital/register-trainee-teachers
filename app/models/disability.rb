# frozen_string_literal: true

# == Schema Information
#
# Table name: disabilities
#
#  id          :bigint           not null, primary key
#  description :string
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_disabilities_on_name  (name) UNIQUE
#
class Disability < ApplicationRecord
  has_many :trainee_disabilities, inverse_of: :disability
  has_many :trainees, through: :trainee_disabilities
end
