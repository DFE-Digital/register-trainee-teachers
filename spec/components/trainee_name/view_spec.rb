# frozen_string_literal: true

require "rails_helper"

module TraineeName
  describe View do
    alias_method :component, :page

    before do
      render_inline(described_class.new(trainee))
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

      it "displays short name" do
        expect(component).to have_text("Joe Blogs")
      end
    end
  end
end
