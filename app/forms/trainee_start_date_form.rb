# frozen_string_literal: true

class TraineeStartDateForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_accessor :trainee, :day, :month, :year

  delegate :id, :persisted?, to: :trainee

  validate :commencement_date_valid

  def initialize(trainee, params = {}, store = FormStore)
    @trainee = trainee
    @store = store
    @params = params
    @new_attributes = fields_from_store.merge(params).symbolize_keys
    super(fields)
  end

  def fields
    {
      day: trainee.commencement_date&.day,
      month: trainee.commencement_date&.month,
      year: trainee.commencement_date&.year,
    }.merge(new_attributes.slice(:day, :month, :year))
  end

  def save!
    if valid?
      update_trainee_commencement_date
      trainee.save!
      store.set(trainee.id, :trainee_start_date, nil)
    else
      false
    end
  end

  def stash
    valid? && store.set(trainee.id, :trainee_start_date, fields)
  end

  def commencement_date
    date_hash = { year: year, month: month, day: day }
    date_args = date_hash.values.map(&:to_i)

    valid_date?(date_args) ? Date.new(*date_args) : OpenStruct.new(date_hash)
  end

private

  attr_reader :new_attributes, :store

  def update_trainee_commencement_date
    trainee.assign_attributes(commencement_date: commencement_date) if errors.empty?
  end

  def commencement_date_valid
    if [day, month, year].all?(&:blank?)
      errors.add(:commencement_date, :blank)
    elsif !commencement_date.is_a?(Date)
      errors.add(:commencement_date, :invalid)
    end
  end

  def valid_date?(date_args)
    Date.valid_date?(*date_args) && date_args.all?(&:positive?)
  end

  def fields_from_store
    store.get(trainee.id, :trainee_start_date).presence || {}
  end
end
