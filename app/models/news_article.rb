# frozen_string_literal: true

class NewsArticle < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true
  validates :summary, presence: true
  validates :date, presence: true
end
