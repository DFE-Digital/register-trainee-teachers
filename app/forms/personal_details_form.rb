class PersonalDetailsForm
  include ActiveModel::Model
  attr_accessor :trainee

  PERSONAL_DETAIL_FIELDS = %w[
    first_names
    middle_names
    last_name
    date_of_birth
    gender
    nationality_ids
  ].freeze

  delegate :id, :persisted?, to: :trainee

  attr_accessor(*PERSONAL_DETAIL_FIELDS)

  validates :first_names, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validates :gender, presence: true
  validate :nationalities_cannot_be_empty

  def initialize(trainee:, params: {})
    @trainee = trainee
    trainee.assign_attributes(params)
    super(trainee.attributes.slice(*PERSONAL_DETAIL_FIELDS).merge(nationality_ids: trainee.nationality_ids))
  end

  def submit
    return false unless valid?

    trainee.save!
  end

private

  def nationalities_cannot_be_empty
    return unless trainee.nationalities.empty?

    errors.add(
      :nationality_ids,
      :empty_nationalities,
    )
  end
end
