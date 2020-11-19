# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskList::View do
  alias_method :component, :page

  let(:status) { nil }

  before(:each) do
    render_inline(TaskList::View.new) do |component|
      component.slot(
        :row,
        task_name: "some key",
        path: "some_path",
        status: status,
      )
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

    describe "tags" do
      context "completed" do
        let(:status) { "completed" }

        it "renders the correct tag status" do
          expect(component.find(".govuk-tag").text).to eq(status)
        end

        it "renders the correct tag colour" do
          expect(component).to have_selector(".govuk-tag--blue")
        end
      end

      context "in progress" do
        let(:status) { "in progress" }

        it "renders the correct tag status" do
          expect(component.find(".govuk-tag").text).to eq(status)
        end

        it "renders the correct tag colour" do
          expect(component).to have_selector(".govuk-tag--grey")
        end
      end

      context "not started" do
        let(:status) { "not started" }

        it "renders the correct tag status" do
          expect(component.find(".govuk-tag").text).to eq(status)
        end

        it "renders the correct tag colour" do
          expect(component).to have_selector(".govuk-tag--grey")
        end
      end
    end
  end
end
