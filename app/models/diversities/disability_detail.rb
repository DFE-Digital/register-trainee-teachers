module Diversities
  class DisabilityDetail
    include ActiveModel::Model
    attr_accessor :trainee, :disability_ids

    delegate :id, :persisted?, to: :trainee
    validate :disabilities_cannot_be_empty

    def initialize(trainee:)
      @trainee = trainee
      super(disability_ids: trainee.disability_ids)
    end

  private

    def disabilities_cannot_be_empty
      return unless trainee.disabilities.empty?

      errors.add(:disability_ids, :empty_disabilities)
    end
  end
end
