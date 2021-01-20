# frozen_string_literal: true

require "rails_helper"

module DynamicBackLink
  describe View do
    alias_method :component, :page

    shared_examples "show page default" do
      it "defaults to trainee show page" do
        expect(component).to have_link(
          "Back to record",
          href: "/trainees/#{trainee.to_param}",
        )
      end
    end

    shared_examples "draft page default" do
      it "defaults to trainee edit page" do
        expect(component).to have_link(
          "Back to draft record",
          href: "/trainees/#{trainee.to_param}/review-draft",
        )
      end
    end

    context "with no origin pages saved" do
      before do
        render_inline(described_class.new(trainee))
      end

      context "and a draft trainee" do
        let(:trainee) { create(:trainee, :draft) }
        include_examples "draft page default"
      end

      context "and a non-draft trainee" do
        let(:trainee) { create(:trainee, :submitted_for_trn) }
        include_examples "show page default"
      end
    end

    context "with origin pages saved" do
      before do
        allow_any_instance_of(Breadcrumbable).to receive(:current_page).and_return(current_page)
        allow_any_instance_of(Breadcrumbable).to receive(:origin_pages_for).with(trainee).and_return(saved_origin_pages)
        render_inline(described_class.new(trainee))
      end

      context "and you're currently on the only saved origin page" do
        let(:current_page) { "trainee_personal_details_confirm" }
        let(:saved_origin_pages) { %w[trainee_personal_details_confirm] }

        context "and the trainee is draft" do
          let(:trainee) { create(:trainee, :draft) }
          include_examples "draft page default"
        end

        context "and the trainee is not draft" do
          let(:trainee) { create(:trainee, :submitted_for_trn) }
          include_examples "show page default"
        end
      end

      context "and you're currently on the last saved origin page of many" do
        let(:trainee) { create(:trainee) }
        let(:current_page) { "trainee_personal_details_confirm" }
        let(:saved_origin_pages) { %w[trainee trainee_personal_details_confirm] }

        it "links to the previous origin page" do
          expect(component).to have_link(
            href: "/trainees/#{trainee.to_param}",
          )
        end
      end

      context "when you're a non-origin page" do
        let(:trainee) { create(:trainee) }
        let(:current_page) { "a_random_page" }
        let(:saved_origin_pages) { %w[trainee trainee_personal_details_confirm] }

        it "links to the last origin page" do
          expect(component).to have_link(
            href: "/trainees/#{trainee.to_param}/personal-details/confirm",
          )
        end
      end
    end
  end
end
