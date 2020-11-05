class ProgrammeDetail
  include ActiveModel::Model
  attr_accessor :trainee

  FIELDS = %w[
    subject
    age_range
    programme_start_date
  ].freeze

  delegate :id, :persisted?, to: :trainee

  attr_accessor(*FIELDS)

  validates :subject, presence: true
  validates :age_range, presence: true
  validates :programme_start_date, presence: true

  def initialize(trainee:)
    @trainee = trainee
    super(trainee.attributes.slice(*FIELDS))
  end
end
