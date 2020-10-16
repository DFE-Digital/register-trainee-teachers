class ConfirmDetail
  include ActiveModel::Model
  attr_accessor :trainee, :mark_as_completed

  def initialize(trainee:)
    @trainee = trainee
    super(mark_as_completed: trainee.progress[:personal_detail])
  end
end
