# frozen_string_literal: true

class TraineeIdForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_accessor :trainee, :trainee_id

  delegate :id, :persisted?, to: :trainee

  validates :trainee_id, presence: true,
                         length: {
                           maximum: 100,
                           message: I18n.t("activemodel.errors.models.trainee_id_form.attributes.trainee_id.max_char_exceeded"),
                         }

  def initialize(trainee, params = {}, store = FormStore)
    @trainee = trainee
    @store = store
    @params = params
    @new_attributes = fields_from_store.merge(params).symbolize_keys
    super(fields)
  end

  def fields
    trainee.attributes
           .symbolize_keys
           .slice(:trainee_id)
           .merge(new_attributes)
  end

  def save!
    if valid?
      update_trainee_id
      trainee.save!
      store.set(trainee.id, :trainee_id, nil)
    else
      false
    end
  end

  def stash
    valid? && store.set(trainee.id, :trainee_id, fields)
  end

private

  attr_reader :new_attributes, :store

  def update_trainee_id
    trainee.assign_attributes(trainee_id: trainee_id) if errors.empty?
  end

  def fields_from_store
    store.get(trainee.id, :trainee_id).presence || {}
  end
end
