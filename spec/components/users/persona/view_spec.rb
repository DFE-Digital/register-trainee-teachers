require "rails_helper"

module Users
  module Persona
    describe View do
      alias_method :component, :page

      context "when users details are provided" do
        before do
          render_inline(View.new(name: "Joe Bloggs",
                                 description: '<p class="test-description">They are hard worker.</p>',
                                 link_path: "testing_path"))
        end

        it "renders users name" do
          expect(component.find("h2")).to have_text("Joe Bloggs")
        end

        it "renders a description" do
          expect(component.find(".test-description")).to have_text("They are hard worker.")
        end

        it "renders a button to login as the user" do
          expect(component.find("form")["action"]).to eq("testing_path")
          expect(component).to have_selector(".govuk-button")
        end
      end
    end
  end
end
