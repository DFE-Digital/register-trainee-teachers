# frozen_string_literal: true

class SubjectSpecialismForm < TraineeForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  FIELDS = %i[
    specialism_1
    specialism_2
    specialism_3
    course_subject_one
    course_subject_two
    course_subject_three
  ].freeze

  ERROR_TRANSLATION_KEY =
    "activemodel.errors.models.subject_specialism_form.attributes.specialism.blank".freeze

  validate :specialism_is_present

  attr_accessor(*FIELDS)

  def initialize(trainee, position, params: {}, user: nil, store: FormStore)
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

  private

  def update_trainee_attributes
    (1..3).each do |i|
      trainee.send("#{subject_attribute(i)}=", fields[:"specialism_#{i}"])
    end
  end

  def compute_fields
    trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
  end

  def subject_attribute(position = @position)
    "course_subject_#{to_word(position)}"
  end

  def specialism_attribute
    @_specialism_attribute ||= "specialism_#{@position}"
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


#/subject_specialism/3
#
#specialism_3
#specialisms[:course_subject_3]
#
#
#if save?
#  if current_position < 3 && specialisms(course_subject#{position+1}.present?
#
#end
