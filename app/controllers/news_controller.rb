# frozen_string_literal: true

class NewsController < ApplicationController
  skip_before_action :authenticate

  def index
    @news_articles = ServiceUpdate.all
  end

  def show
    @news_article = ServiceUpdate.find(params[:id])
  end
end
