# frozen_string_literal: true

require "rails_helper"

RSpec.describe PageTitle::View do
  before do
    allow(I18n).to receive(:t).with("service_name").and_return("Cool Service")
  end

  context "given a string that is not in the format of an i18n path" do
    it "constructs a page title using the provided value" do
      component = PageTitle::View.new(title: "Some title")
      page_title = component.build_page_title
      expect(page_title).to eq("Some title - Cool Service - GOV.UK")
    end
  end

  context "given an i18n key format" do
    before do
      allow(I18n).to receive(:t).with("components.page_titles.trainee.new").and_return("New Trainee")
    end

    it "constructs a page title value" do
      component = PageTitle::View.new(title: "trainee.new")
      page_title = component.build_page_title
      expect(page_title).to eq("New Trainee - Cool Service - GOV.UK")
    end

    it "constructs a page title value with an error" do
      component = PageTitle::View.new(title: "trainee.new", errors: "Loads")
      page_title = component.build_page_title
      expect(page_title).to eq("Error: New Trainee - Cool Service - GOV.UK")
    end
  end
end
