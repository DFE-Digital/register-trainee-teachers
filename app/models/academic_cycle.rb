# frozen_string_literal: true

# == Schema Information
#
# Table name: academic_cycles
#
#  id         :bigint           not null, primary key
#  end_date   :date             not null
#  published  :boolean          default(FALSE), not null
#  start_date :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  academic_cycles_date_range  (tsrange((start_date)::timestamp without time zone, (end_date)::timestamp without time zone)) USING gist
#
class AcademicCycle < ApplicationRecord
  has_many :funding_methods
  has_many :funding_publication_requests, dependent: :destroy

  validates :start_date, :end_date, presence: true
  validate :start_date_before_end_date

  scope :trainees_filter, -> { order(start_date: :desc).limit(3) }
  scope :since_year, ->(year) { where(start_date: Date.new(year)..) }

  def self.for_year(year)
    where("extract(year from start_date) = ?", year.to_i).first
  end

  def self.for_date(date)
    where("end_date >= :date AND start_date <= :date", date:).first
  end

  def self.current
    for_date(Time.zone.now)
  end

  def self.previous
    for_date(1.year.ago)
  end

  def self.next
    for_date(1.year.from_now)
  end

  def total_trainees
    trainees_starting.or(trainees_ending).or(Trainee.where(start_cycle: { start_date: ...start_date })
    .where("end_cycle.start_date > ?", start_date))
    .joins("INNER JOIN academic_cycles start_cycle ON trainees.start_academic_cycle_id = start_cycle.id")
    .joins("INNER JOIN academic_cycles end_cycle ON trainees.end_academic_cycle_id = end_cycle.id")
  end

  def trainees_starting
    trainee_scope = Trainee.where(start_academic_cycle: self)
    trainee_scope = trainee_scope.or(Trainee.where(start_academic_cycle: nil)) if current?
    trainee_scope
  end

  def trainees_ending
    trainee_scope = Trainee.where(end_academic_cycle: self)
    trainee_scope = trainee_scope.or(Trainee.where(end_academic_cycle: nil)) if current?
    trainee_scope
  end

  def start_year
    start_date.year
  end

  def end_year
    end_date.year
  end

  def previous
    self.class.for_year(start_year - 1)
  end

  def label(text = " to ")
    "#{start_year}#{text}#{start_year + 1}"
  end

  def current?
    (start_date.beginning_of_day..end_date.end_of_day).cover?(Time.zone.now)
  end

  # Funding-management status of the year, combining the calendar with the
  # `published` flag:
  #   :past      — the year has ended (end_date < today)
  #   :live      — the current year (start_date <= today <= end_date)
  #   :published — a future year whose funding has been explicitly published
  #   :draft     — a future year, funding still provisional
  def status
    today = Time.zone.now.to_date
    return :past if end_date < today
    return :live if (start_date..end_date).cover?(today)
    return :awaiting_approval if awaiting_publication_approval?

    published? ? :published : :draft
  end

  def past?  = status == :past
  def live?  = status == :live
  def draft? = status == :draft
  def awaiting_publication_approval? = funding_publication_requests.awaiting_approval.exists?

  # Approved, waiting for the year's start date to go live (shown as "Ready for release").
  def ready_for_release? = status == :published

  # Not live yet: draft, awaiting approval or ready for release. These years are
  # listed under Drafts; Requirements shows them once they go live.
  def pre_release? = %i[draft awaiting_approval published].include?(status)

  # A year funding management runs only for EYTDA (2026 to 2027): other routes
  # keep their rules in code. EYTDA funding can be drafted for it, and signed
  # off, even after it has gone live.
  def eytda_only_funding_year?
    !past? && start_year >= FundingManager::EYTDA_FUNDING_MANAGEMENT_START_YEAR &&
      start_year < FundingManager::FUNDING_MANAGEMENT_START_YEAR
  end

  # EYTDA funding can still be added, changed or signed off for this year.
  def eytda_funding_draftable?
    eytda_only_funding_year? && !published? && !awaiting_publication_approval?
  end

  # Locked for every route except EYTDA (it has gone live, but EYTDA can still be drafted).
  def locked_except_eytda?
    funding_locked? && eytda_funding_draftable?
  end

  # The funding records Drafts and sign-off look after for this year: only EYTDA's
  # in a year funding management runs only for EYTDA (the others are older data).
  def draft_funding_methods
    eytda_only_funding_year? ? funding_methods.where(training_route: FundingManager::EYTDA_ROUTE) : funding_methods
  end

  # Signed-off EYTDA funding for a year that has already started.
  def eytda_funding_approved? = eytda_only_funding_year? && published?

  # The approval behind a Ready for release year (who approved it and when).
  def latest_approval = funding_publication_requests.approved.latest_first.first

  # Funding reference data for a year is locked once the year has gone live (or
  # ended) — it is in use registering trainees and must not change. Only future
  # years can have funding added or removed. Independent of any feature flag or
  # approval state; those add further, softer locks on top of this one.
  def funding_locked? = live? || past?

  # The open submit→decision cycle, if one is in progress.
  def pending_publication_request = funding_publication_requests.awaiting_approval.latest_first.first

  def in_performance_profile_range?(date)
    performance_profile_date_range.cover?(date)
  end

  def first_day_of_year
    Date.new(end_year + 1, 1, 1)
  end

  def second_monday_of_january
    return first_day_of_year.next_week(:monday) + 7 if first_day_of_year.wday > 1

    first_day_of_year.next_week(:monday)
  end

  def last_day_of_february
    Date.new(end_year + 1, 2, -1)
  end

  def first_day_of_october
    Date.new(start_year, 10, 1)
  end

  def second_wednesday_of_october
    return first_day_of_october.next_week(:wednesday) + 7 if first_day_of_october.wday > 3

    first_day_of_october.next_week(:wednesday)
  end

  def first_day_of_september
    Date.new(start_year, 9, 1)
  end

  def last_day_of_october
    Date.new(start_year, 10, -1)
  end

  def in_census_range?(date)
    census_date_range.cover?(date)
  end

  alias_method :end_date_of_performance_profile, :last_day_of_february

  alias_method :itt_census_date, :second_wednesday_of_october

  alias_method :itt_census_end_date, :last_day_of_october

  def performance_profile_date_range
    @performance_profile_date_range ||= second_monday_of_january..end_date_of_performance_profile
  end

  def census_date_range
    @census_date_range ||= first_day_of_september..last_day_of_october
  end

private

  def start_date_before_end_date
    return unless dates_available?

    if start_date > end_date
      errors.add(:start_date, "must be before end date")
    end
  end

  def dates_available?
    start_date && end_date
  end
end
