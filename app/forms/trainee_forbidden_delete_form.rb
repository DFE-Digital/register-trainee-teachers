# frozen_string_literal: true

class TraineeForbiddenDeleteForm
  include ActiveModel::Model

  attr_accessor :alternative_option

  validates :alternative_option, presence: true, inclusion: { in: %w[defer withdraw exit] }

  def initialize(params = {})
    @alternative_option = params[:alternative_option]
  end

  def defer?
    alternative_option == "defer"
  end

  def withdraw?
    alternative_option == "withdraw"
  end
end
