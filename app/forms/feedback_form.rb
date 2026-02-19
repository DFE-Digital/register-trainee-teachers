# frozen_string_literal: true

class FeedbackForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment

  FIELDS = %i[satisfaction_level improvement_suggestion name email].freeze

  attr_accessor :satisfaction_level, :improvement_suggestion, :name, :email

  validates :satisfaction_level, presence: true, inclusion: { in: Feedback.satisfaction_levels.keys }
  validates :improvement_suggestion, presence: true

  def initialize(store_id, params: {})
    @store_id = store_id
    @params = params
    assign_attributes(compute_fields)
  end

  def stash
    return false unless valid?

    FormStore.set(store_id, form_store_key, fields)
  end

  # rubocop:disable Naming/PredicateMethod
  def save
    return false unless valid?

    create_feedback!
    send_confirmation_email
    clear_stash
    true
  end
  # rubocop:enable Naming/PredicateMethod

  def stashed?
    fields_from_store.present?
  end

  def satisfaction_level_text
    return if satisfaction_level.blank?

    satisfaction_level.humanize
  end

private

  def create_feedback!
    Feedback.create!(
      satisfaction_level: satisfaction_level,
      improvement_suggestion: improvement_suggestion,
      name: name.presence,
      email: email.presence,
    )
  end

  def send_confirmation_email
    FeedbackSubmittedMailer.generate(
      satisfaction_level: satisfaction_level_text,
      improvement_suggestion: improvement_suggestion,
      name: name,
      email: email,
    ).deliver_later
  end

  def clear_stash
    FormStore.set(store_id, form_store_key, nil)
  end

  def compute_fields
    fields_from_store.merge(@params).symbolize_keys.slice(*FIELDS)
  end

  def fields
    FIELDS.index_with { |field| public_send(field) }
  end

  def fields_from_store
    FormStore.get(store_id, form_store_key).presence || {}
  end

  attr_reader :store_id

  def form_store_key
    self.class.name.underscore.chomp("_form").split("/").last.to_sym
  end
end
