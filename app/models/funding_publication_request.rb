# frozen_string_literal: true

# One submit → decision cycle for publishing an academic year's funding
# (the maker-checker / two-person approval flow). A cycle can accumulate many
# of these over time; at most one is `awaiting_approval` at once. The set of
# rows is the audit trail (who submitted / reviewed, when, and why on reject).
# == Schema Information
#
# Table name: funding_publication_requests
#
#  id                :bigint           not null, primary key
#  decision_notes    :text
#  reviewed_at       :datetime
#  state             :integer          default(0), not null
#  submitted_at      :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  academic_cycle_id :bigint           not null
#  reviewed_by_id    :bigint
#  submitted_by_id   :bigint
#
# Indexes
#
#  index_funding_publication_requests_on_academic_cycle_id  (academic_cycle_id)
#
class FundingPublicationRequest < ApplicationRecord
  belongs_to :academic_cycle
  belongs_to :submitted_by, class_name: "User", optional: true
  belongs_to :reviewed_by, class_name: "User", optional: true

  enum :state, {
    awaiting_approval: 0,
    approved: 1,
    rejected: 2,
    withdrawn: 3,
  }

  scope :latest_first, -> { order(created_at: :desc) }

  def submitted_by?(user)
    user.present? && submitted_by_id == user.id
  end
end
