# frozen_string_literal: true

require "rails_helper"

describe OriginPage do
  let(:review_draft_trainee_path) { "/trainees/#{trainee.slug}/review-draft" }
  let(:trainee_personal_details_confirm_path) { "/trainees/#{trainee.slug}/personal-details/confirm" }
  let(:session) { { "origin_pages_for_#{trainee.id}" => origin_pages } }

  subject { described_class.new(trainee, session, request) }

  describe "#path" do
    context "trainee is in draft state" do
      let(:trainee) { create(:trainee, :draft) }

      context "GET request" do
        let(:request) { double(path_info: request_path, head?: false, get?: true, patch?: false, put?: false) }

        context "no origin pages saved" do
          let(:request_path) { review_draft_trainee_path }
          let(:origin_pages) { [] }

          it "returns the path to trainee review draft page" do
            expect(subject.path).to eq(review_draft_trainee_path)
          end
        end

        context "1 origin page saved" do
          let(:request_path) { review_draft_trainee_path }
          let(:origin_pages) { %w[review_draft_trainee] }

          it "returns the path to the last origin page" do
            expect(subject.path).to eq(review_draft_trainee_path)
          end
        end

        context "2 origin pages saved" do
          let(:request_path) { trainee_personal_details_confirm_path }
          let(:origin_pages) { %w[review_draft_trainee trainee_personal_details_confirm] }

          it "returns the path to the first origin page" do
            expect(subject.path).to eq(review_draft_trainee_path)
          end
        end
      end

      context "PUT request" do
        let(:request_path) { trainee_personal_details_confirm_path }
        let(:request) { double(path_info: request_path, head?: false, get?: false, patch?: false, put?: true) }

        context "2 origin pages saved" do
          let(:origin_pages) { %w[review_draft_trainee trainee_personal_details_confirm] }

          context "last page visited was a confirmation page" do
            it "returns the path to the page before the confirmation page" do
              expect(subject.path).to eq(review_draft_trainee_path)
            end
          end
        end
      end
    end
  end
end
