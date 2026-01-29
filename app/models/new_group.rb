# frozen_string_literal: true

# == Schema Information
#
# Table name: new_groups
#
#  id          :bigint           not null, primary key
#  description :string
#  email       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class NewGroup < ApplicationRecord
end
