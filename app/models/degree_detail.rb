# frozen_string_literal: true

class DegreeDetail
  include ActiveModel::Model

  attr_accessor :trainee, :degree_ids

  validate :degrees_cannot_be_empty

  def initialize(trainee)
    @trainee = trainee
    super(fields)
  end

  def fields
    { degree_ids: trainee.degree_ids }
  end

private

  def degrees_cannot_be_empty
    errors.add(:degree_ids, :empty_degrees) if trainee.degrees.empty?
  end
end
