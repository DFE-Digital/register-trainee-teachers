class PersonalDetail
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_accessor :trainee

  FIELDS = %w[
    first_names
    middle_names
    last_name
    date_of_birth
    gender
    nationality_ids
  ].freeze

  delegate :id, :persisted?, to: :trainee

  after_validation :update_trainee

  attr_accessor(*FIELDS)

  validates :first_names, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validates :gender, presence: true, inclusion: { in: Trainee.genders.keys }
  validate :nationalities_cannot_be_empty

  def initialize(trainee)
    @trainee = trainee
    super(fields)
  end

  def fields
    trainee.attributes.slice(*FIELDS).merge(nationality_ids: trainee.nationality_ids)
  end

private

  attr_reader :attributes

  def nationalities_cannot_be_empty
    return unless trainee.nationalities.empty?

    errors.add(:nationality_ids, :empty_nationalities)
  end

  def update_trainee
    trainee.save! if errors.empty?
  end
end
