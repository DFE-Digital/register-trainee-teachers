# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskList::View do
  alias_method :component, :page

  let(:status) { nil }

  before(:each) do
    render_inline(TaskList::View.new) do |component|
      component.row(
        task_name: "some key",
        path: "some_path",
        status: status,
      )
    end
  end

  shared_examples "status indicator" do |status, colour|
    let(:status) { status }

    context status do
      it "renders the correct tag status" do
        expect(component.find(".govuk-tag").text).to include(status)
      end

      it "renders the correct tag colour" do
        expect(component).to have_selector(".govuk-tag--#{colour}")
      end
    end
  end

  context "when task data is provided" do
    context "rendered tasks" do
      it "renders a list of tasks" do
        expect(component).to have_selector(".app-task-list__item")
      end

      it "renders the task name" do
        expect(component).to have_link("some key", href: "some_path")
      end
    end

    it_behaves_like("status indicator", "completed", "blue")
    it_behaves_like("status indicator", "in progress", "grey")
    it_behaves_like("status indicator", "review", "pink")
    it_behaves_like("status indicator", "not started", "grey")
  end

  describe "#status_id" do
    subject do
      TaskList::View::Row.new(
        task_name: "some key",
        path: "some_path",
        status: "completed",
      )
    end

    it "returns a string id of the row status" do
      expect(subject.status_id).to eq("some-key-status")
    end
  end

  describe "#get_path" do
    subject do
      TaskList::View::Row.new(
        task_name: "some key",
        path: path,
        confirm_path: confirm_path,
        status: status,
      )
    end
    let(:confirm_path) { -> { raise hell } }
    let(:path) { "some_path" }

    context "when the status is not started" do
      let(:status) { "not started" }

      context "when the path provided is a string" do
        it "returns the path" do
          expect(subject.get_path).to eq "some_path"
        end
      end

      context "when the path provided is callable" do
        let(:path) { -> { "some_path" } }

        it "calls the callable and returns the result" do
          expect(subject.get_path).to eq "some_path"
        end
      end
    end

    context "when the status is in progress" do
      let(:status) { "in_progress" }

      context "when the confirm_path provided is a string" do
        let(:confirm_path) { "confirm_path" }

        it "returns the confirm_path" do
          expect(subject.get_path).to eq "confirm_path"
        end
      end

      context "when the confirm_path provided is callable" do
        let(:confirm_path) { -> { "confirm_path" } }

        it "calls the callable and returns the result" do
          expect(subject.get_path).to eq "confirm_path"
        end
      end
    end
  end
end
