class FundingManager
  def initialize(trainee)
    @trainee = trainee
  end

  def bursary_amount
    available_bursary_amount

  def funding_available?
    funding_method.includes(:bursary_subjects).where.not(bursary_subjects: { id: nil })
      .where(training_route: training_route).present?
  end

private

  attr_reader :trainee

  delegate :training_route, :course_subject_one, to: :trainee

  def available_bursary_amount
    available_amount(:bursary)
  end

  def available_amount(_funding_type)
    if (allocation_subject = SubjectSpecialism.find_by(name: course_subject_one)&.allocation_subject)
      # allocation_subject.bursaries.find_by(training_route: training_route, funding_type: funding_type)&.amount
      allocation_subject.bursaries.find_by(training_route: training_route)&.amount
    end
  end

  def funding_method
    Bursary
  end
end
