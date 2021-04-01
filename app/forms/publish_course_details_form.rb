# frozen_string_literal: true

class PublishCourseDetailsForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment

  NOT_LISTED = "not_listed"

  FIELDS = %i[
    code
  ].freeze

  attr_accessor(*FIELDS, :trainee, :fields)

  delegate :id, :persisted?, to: :trainee

  validates :code, presence: true

  def initialize(trainee, params = {}, store = FormStore)
    @trainee = trainee
    @store = store
    @fields = fields_from_store.merge(params).symbolize_keys
    super(fields)
  end

  def stash
    valid? && store.set(trainee.id, :course_code, fields)
  end

  def manual_entry_chosen?
    code == NOT_LISTED
  end

private

  attr_reader :store

  def fields_from_store
    store.get(trainee.id, :course_code).presence || {}
  end
end
