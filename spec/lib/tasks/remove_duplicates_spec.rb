# frozen_string_literal: true

require "rails_helper"
require "rake"

RSpec.describe "trainee:remove_duplicates" do
  before do
    Rake.application.rake_require("tasks/remove_duplicates")
    Rake::Task.define_task(:environment)
  end

  let(:task) { Rake::Task["trainee:remove_duplicates"] }
  let(:csv_path) { Rails.root.join("spec/fixtures/files/duplicate_trainees.csv") }

  context "with valid CSV file" do
    it "removes duplicate trainees based on email" do
      create(:trainee, id: "123", email: "duplicate@example.com")
      create(:trainee, id: "456", email: "duplicate@example.com")
      create(:trainee, id: "789", email: "duplicate@example.com")
      create(:trainee, id: "890", email: "unique@example.com")

      expect {
        task.invoke(csv_path.to_s)
      }.to change { Trainee.count }.by(-2)
    end
  end

  context "with invalid CSV file path" do
    it "raises an error" do
      invalid_csv_path = Rails.root.join("spec/fixtures/files/non_existent.csv")

      expect {
        task.invoke(invalid_csv_path.to_s)
      }.to raise_error(SystemExit).and output(/Please provide a valid file path/).to_stdout
    end
  end
end
