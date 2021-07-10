# frozen_string_literal: true

class SubjectSpecialismForm < TraineeForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  FIELDS = %i[
    specialism1
    specialism2
    specialism3
    course_subject_one
    course_subject_two
    course_subject_three
  ].freeze

  ERROR_TRANSLATION_KEY =
    "activemodel.errors.models.subject_specialism_form.attributes.specialism.blank"

  validate :specialism_is_present

  attr_accessor(*FIELDS)

  def initialize(trainee, position = nil, params: {}, user: nil, store: FormStore)
    @position = position
    @trainee = trainee
    super(trainee, params: params, user: user, store: store)
  end

  def save!
    if valid?
      update_trainee_attributes
      trainee.save!
      store.set(trainee.id, :subject_specialism, nil)
    else
      false
    end
  end

  def specialisms
    [specialism1, specialism2, specialism3].compact
  end

private

  def update_trainee_attributes
    (1..3).each do |i|
      trainee.send("#{subject_attribute(i)}=", fields[:"specialism#{i}"])
    end
  end

  def compute_fields
    trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
  end

  def subject_attribute(position = @position)
    "course_subject_#{to_word(position)}"
  end

  def specialism_attribute
    @_specialism_attribute ||= "specialism#{@position}"
  end

  def to_word(number)
    case number
    when 1
      "one"
    when 2
      "two"
    when 3
      "three"
    end
  end

  def specialism_is_present
    if @position && send(specialism_attribute).blank?
      errors.add(specialism_attribute, I18n.t(ERROR_TRANSLATION_KEY))
    end
  end

  def form_store_key
    :subject_specialism
  end
end
