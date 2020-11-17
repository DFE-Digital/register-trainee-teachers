# frozen_string_literal: true

require "rails_helper"

RSpec.describe PageTitle::View do
  def locale_setup
    allow(I18n).to receive(:t).with("components.page_titles.trainee.new").and_return("New Trainee")
    allow(I18n).to receive(:t).with("service_name").and_return("Cool Service")
  end

  it "constructs a page title value" do
    locale_setup
    component = PageTitle::View.new(title: "trainee.new")
    page_title = component.build_page_title
    expect(page_title).to eq("New Trainee - Cool Service - GOV.UK")
  end

  it "constructs a page title value with an error" do
    locale_setup
    component = PageTitle::View.new(title: "trainee.new", errors: "Loads")
    page_title = component.build_page_title
    expect(page_title).to eq("Error: New Trainee - Cool Service - GOV.UK")
  end
end
