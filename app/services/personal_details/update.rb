module PersonalDetails
  class Update
    attr_reader :trainee, :personal_detail, :successful

    alias_method :successful?, :successful

    class << self
      def call(**args)
        new(**args).call
      end
    end

    def initialize(trainee:, attributes: {})
      @trainee = trainee
      trainee.assign_attributes(attributes)
      @personal_detail = PersonalDetail.new(trainee: trainee)
    end

    def call
      @successful = personal_detail.valid? && trainee.save!
      self
    end
  end
end
