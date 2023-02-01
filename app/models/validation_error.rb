# frozen_string_literal: true

# == Schema Information
#
# Table name: validation_errors
#
#  id          :bigint           not null, primary key
#  details     :jsonb
#  form_object :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint
#
# Indexes
#
#  index_validation_errors_on_user_id  (user_id)
#
class ValidationError < ApplicationRecord
  validates :form_object, presence: true

  belongs_to :user

  def self.list_of_distinct_errors_with_count
    distinct_errors = all.flat_map do |e|
      e.details.flat_map do |attribute, details|
        details["messages"].map do |message|
          [e.form_object, attribute, message]
        end
      end
    end

    distinct_errors.tally.sort_by { |_a, b| b }.reverse
  end
end
