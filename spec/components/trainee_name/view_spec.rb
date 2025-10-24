# frozen_string_literal: true

require "rails_helper"

module TraineeName
  describe View do
    alias_method :component, :page
    let(:prefix) { nil }

    before do
      render_inline(described_class.new(trainee, prefix:))
    end

    context "name not set" do
      context "draft trainee" do
        let(:trainee) { build(:trainee, first_names: nil, middle_names: nil, last_name: nil) }

        it "displays draft" do
          expect(component).to have_text("Draft")
        end
      end

      context "non draft trainee" do
        let(:trainee) { build(:trainee, :submitted_for_trn, first_names: nil, middle_names: nil, last_name: nil) }

        it "does not display draft" do
          expect(component).not_to have_text("Draft")
        end
      end
    end

    context "name is set" do
      let(:trainee) { build(:trainee, first_names: "Joe", middle_names: "Smith", last_name: "Blogs") }
      let(:prefix) { "The Magnificent -" }

      it "displays short name" do
        expect(component).to have_text("Joe Blogs")
      end

      context "with a prefix" do
        it "displays a prefixed short name" do
          expect(component).to have_text("The Magnificent - Joe Blogs")
        end
      end
    end
  end
end
