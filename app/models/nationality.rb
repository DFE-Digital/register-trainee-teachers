# frozen_string_literal: true

# == Schema Information
#
# Table name: nationalities
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_nationalities_on_name  (name) UNIQUE
#
class Nationality < ApplicationRecord
  has_many :nationalisations, inverse_of: :nationality
  has_many :trainees, through: :nationalisations

  NATIONALITIES = [
    Dttp::CodeSets::Nationalities::BRITISH,
    Dttp::CodeSets::Nationalities::IRISH,
  ].freeze

  EXCLUDED_NATIONALITIES = [
    Dttp::CodeSets::Nationalities::CYPRIOT,
  ].freeze

  scope :default, -> { where(name: NATIONALITIES) }
  scope :other, -> { where.not(name: EXCLUDED_NATIONALITIES) }
end
